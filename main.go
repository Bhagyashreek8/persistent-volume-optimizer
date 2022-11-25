package main

import (
	"bytes"
	"flag"
	"fmt"
	"github.com/golang/glog"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/fields"
	"k8s.io/apimachinery/pkg/util/wait"
	"k8s.io/client-go/kubernetes"
	_ "k8s.io/client-go/plugin/pkg/client/auth/oidc"
	"k8s.io/client-go/tools/cache"
	"k8s.io/client-go/tools/clientcmd"
	"log"
	"os/exec"
	"strings"
	"syscall"
	"time"
)

const (
	vpcProvisioner = "vpc.block.csi.ibm.io"
	s3fsProvisioner = "ibm.io/ibmc-s3fs"
	cmNamePrefix = "pvc-optimizer"
	mountFailed = "FailedMount"
)

var master = flag.String(
	"master",
	"",
	"Master URL to build a client config from. Either this or kubeconfig needs to be set if the provisioner is being run out of cluster.",
)


// /Users/bhagyashree/.bluemix/plugins/container-service/clusters/bha-blk-cos-hackathon-cddqn4q20b8mu62tdjb0/kube-config-aaa00-bha-blk-cos-hackathon.yml
var kubeconfig = flag.String(
	"kubeconfig",
	"/Users/bhagyashree/.bluemix/plugins/container-service/clusters/bha-blk-cos-hackathon-cddqn4q20b8mu62tdjb0/kube-config-aaa00-bha-blk-cos-hackathon.yml",
	"Absolute path to the kubeconfig file. Either this or master needs to be set if the provisioner is being run out of cluster.",
)

func main() {
	flag.Parse()
	log.Println("Welcome to persistent-volume-optimizer")
	restConfig, err := clientcmd.BuildConfigFromFlags(*master, *kubeconfig)
	if err != nil {
		glog.Errorln(err)
	}

	k8sclient, err := kubernetes.NewForConfig(restConfig)
	if err != nil {
		glog.Errorln(err)
	}

	WatchConfigmap(k8sclient)

}

func WatchConfigmap(k8sclient kubernetes.Interface) {
	watchlist := cache.NewListWatchFromClient(
		k8sclient.CoreV1().RESTClient(),
		string(v1.ResourceConfigMaps),
		v1.NamespaceAll,
		fields.Everything(),
	)

	_, controller := cache.NewInformer( // also take a look at NewSharedIndexInformer
		watchlist,
		&v1.ConfigMap{},
		30 * time.Second, //Duration is int64
		cache.ResourceEventHandlerFuncs{
			AddFunc: func(obj interface{}) {
				fmt.Printf("configmap added \n")
				cmobj, ok := obj.(*v1.ConfigMap)
				if !ok {
					log.Println("Error in reading watcher event data of config map")
				}
				fetchConfigMap(cmobj)
			},
			DeleteFunc: nil,
			UpdateFunc: nil,
		},
	)

	stopch := wait.NeverStop
	go controller.Run(stopch)
	log.Println("WatchConfigMap")
	<-stopch
}

func fetchConfigMap(cmobj *v1.ConfigMap) {
	var srcVolPath, destVolPath, policy string
	cmName := cmobj.Name
	//cmStatus := fmt.Sprintf("%v", cmobj.Status.Phase)
	if strings.Contains(cmName, cmNamePrefix) {
		log.Println("configmap name", cmobj.Name)
		log.Println("configmap cmobj.Data", cmobj.Data)
		cmData := cmobj.Data

		srcVolPath = cmData["source-volume-path"]
		destVolPath = cmData["dest-volume-path"]
		policy = cmData["policy"]
		log.Println("configmap srcVol", srcVolPath)
		log.Println("configmap destVol", destVolPath)
		log.Println("configmap destVol", policy)

		//call the script to move the files
		_, _, err := ExecuteCommand("./scripts/moveData.sh")
		if err != "" {
			fmt.Println(err)
		}
	}

		//Fetch events for this PVC
		// kubectl get events --field-selector involvedObject.kind=PersistentVolumeClaim,involvedObject.name=csi-block-pvc-good -n default
		//getPvcEventsCmd := "kubectl get events --field-selector involvedObject.kind=PersistentVolumeClaim,involvedObject.name=" + cmobj.Name + " -n " + cmobj.Namespace
		//_, pvcEvents, err := ExecuteCommand(getPvcEventsCmd)
		//if err != "" {
		//	fmt.Println(err)
		//}
		//fmt.Println("PVC Events: \n", pvcEvents)

}

func topNodes() string {
	topNodesCmd := "kubectl top nodes"

	_, out, err := ExecuteCommand(topNodesCmd)
	if err != "" {
		fmt.Println(err)
	}
	return out
}

func enableVPCProvisioner() {
	enableVPCDriverStatefulSetCmd := "kubectl scale --replicas=1 -n kube-system StatefulSet ibm-vpc-block-csi-controller"
	enableVPCDriverDaemonSetCmd := "kubectl patch daemonset ibm-vpc-block-csi-node --type json -p='[{\"op\": \"remove\", \"path\": \"/spec/template/spec/nodeSelector/non-existing\"}]' -n kube-system"

	_, _, err := ExecuteCommand(enableVPCDriverStatefulSetCmd)
	if err != "" {
		fmt.Println(err)
	}
	_, _, err = ExecuteCommand(enableVPCDriverDaemonSetCmd)
	if err != "" {
		fmt.Println(err)
	}
	log.Println("vpc block driver enabled ")
}


// ExecuteCommand to execute shell commands
func ExecuteCommand(command string) (int, string, string) {
	fmt.Println("in ExecuteCommand - cmd : ", command)
	var cmd *exec.Cmd
	var cmdErr bytes.Buffer
	var cmdOut bytes.Buffer
	cmdErr.Reset()
	cmdOut.Reset()

	cmd = exec.Command("bash", "-c", command)
	cmd.Stderr = &cmdErr
	cmd.Stdout = &cmdOut
	err := cmd.Run()

	var waitStatus syscall.WaitStatus

	errStr := strings.TrimSpace(cmdErr.String())
	outStr := strings.TrimSpace(cmdOut.String())

	if err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			waitStatus = exitError.Sys().(syscall.WaitStatus)
		}
		if errStr != "" {
			fmt.Println(command)
			fmt.Println(errStr)
		}
	} else {
		waitStatus = cmd.ProcessState.Sys().(syscall.WaitStatus)
	}
	if waitStatus.ExitStatus() == -1 {
		fmt.Print(time.Now().String() + " Timed out " + command)
	}
	return waitStatus.ExitStatus(), outStr, errStr
}
