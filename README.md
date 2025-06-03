# IaC Container Edge

### Infraestructura como código (IaC) para desplegar un entorno completo de WordPress en AWS utilizando ECS, PostgreSQL, EFS y servicios complementarios. Este proyecto permite gestionar y versionar toda la infraestructura de manera automatizada y reproducible con Terraform.

## Variables de configuración

### Crea un archivo llamado `default.tfvars` (o el nombre que prefieras, por ejemplo, `develop.tfvars`) en la raíz del proyecto con el siguiente contenido:

```hcl
nginx_image        = ""
domain_name        = "example.com"
public_ip_cidr     = "0.0.0.0/32"
vpc_cidr           = "10.10.0.0/22"
aws_region         = "us-east-1"
environment        = "development"
owner              = "Your Name"
project            = "Your Project Name"
```

**Importante:**

### No subas este archivo a GitHub. Añádelo a tu `.gitignore`.

## Uso

### Para aplicar la configuración usando tu archivo de variables:

```sh
terraform init
terraform validate
terraform plan -var-file="default.tfvars" --out tfplan
terraform apply "tfplan"
```

## Despliegue por módulo

Si deseas desplegar únicamente un módulo específico (por ejemplo, solo la VPC), puedes utilizar el parámetro `-target` de Terraform. Por ejemplo:

```sh
terraform init
terraform plan -var-file="default.tfvars" -target=module.vpc
terraform apply -var-file="default.tfvars" -target=module.vpc
```

Esto aplicará únicamente los recursos definidos en el módulo indicado. Puedes cambiar `module.vpc` por cualquier otro módulo según lo necesites.


## Ver los outputs

### Después de aplicar tu plan, puedes ver los valores de salida definidos en tus módulos con:

```sh
terraform show -json | jq '.values.outputs'
```

### O simplemente:

```sh
terraform output
```
