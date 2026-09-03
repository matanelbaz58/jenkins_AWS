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
                    # ביטול בקשת אישור טביעת אצבע (Fingerprint) בחיבור SSH ראשוני לשרתים החדשים
                    export ANSIBLE_HOST_KEY_CHECKING=False
                    
                    # הרצת ה-Playbook להתקנת הקוברנטיס תוך שימוש במפתח הפרטי
                    ansible-playbook --private-key $SSH_KEY -i inventory.ini k8s_setup.yml -u ubuntu
                    '''
                }
            }
        }
    }
}
