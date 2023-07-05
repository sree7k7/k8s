1. list namespace: `k get ns -A`
2. Create a single Pod of image httpd:2.4.41-alpine in Namespace default. 
 The Pod should be named pod1 and the container should be named pod1-container.
 Your manager would like to run a command manually on occasion to output the status of 
 that exact Pod. Please write a command that does this into /opt/course/2/pod1-status-command.sh. The command should use kubectl.
- solution:
[pod](task1_pod1.yaml)
```
vi /opt/course/2/pod1-status-command.sh
kubectl describe pod pod1 -n default | grep -i status:
```

3. Team Neptune needs a Job template located at /opt/course/3/job.yaml. This Job should run image busybox:1.31.0 and execute sleep 2 && echo done. It should be in namespace neptune, run a total of 3 times and should execute 2 runs in parallel.

Start the Job and check its history. Each pod created by the Job should have the label id: awesome-job. The job should be named neb-new-job and the container neb-new-job-container.

- Solution
[neptune](neptune.yaml)

