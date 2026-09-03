[master]
${master_ip} ansible_user=ubuntu ansible_ssh_private_key_file=my-lab-key.pem

[workers]
%{ for ip in worker_ips ~}
${ip} ansible_user=ubuntu ansible_ssh_private_key_file=my-lab-key.pem
%{ endfor ~}