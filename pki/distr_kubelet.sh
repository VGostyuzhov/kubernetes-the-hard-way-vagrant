for instance in worker-0 worker-1 ; do
    scp ca/ca.pem kubelet/${isntance}-key.pem kubelet/${instance}.pem ${instance}:~/
done 
