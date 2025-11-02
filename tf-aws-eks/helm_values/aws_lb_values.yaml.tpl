clusterName: ${cluster_name}
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}
