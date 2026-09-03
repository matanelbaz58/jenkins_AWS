pipeline {
    agent any

    stages {
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Apply') {
            steps {
                // מריץ את יצירת השרתים ב-AWS באופן אוטומטי
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Ansible K8s Setup') {
            steps {
                // שולף את מפתח ה-SSH שהגדרנו קודם ב-Credentials תחת השם aws-lab-key
                withCredentials([sshUserPrivateKey(credentialsId: 'aws-lab-key', keyFileVariable: 'SSH_KEY')]) {
                    sh '''
                    # העתקת המפתח מהמשתנה של ג'נקינס לקובץ המקומי שדורש ה-inventory
                    cp $SSH_KEY my-lab-key.pem
                    chmod 600 my-lab-key.pem

                    # המתנה של 30 שניות כדי לאפשר לשרתים החדשים ב-AWS להפעיל את שירות ה-SSH
                    echo "Waiting for EC2 instances to initialize SSH..."
                    sleep 30

                    # ביטול בקשת אישור טביעת אצבע (Fingerprint) בחיבור SSH ראשוני לשרתים החדשים
                    export ANSIBLE_HOST_KEY_CHECKING=False

                    # הרצת ה-Playbook להתקנת הקוברנטיס תוך שימוש במפתח המקומי
                    ansible-playbook --private-key my-lab-key.pem -i inventory.ini k8s_setup.yml -u ubuntu
                    '''
                }
            }
        }
    }
}



