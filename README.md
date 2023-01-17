# tfmermaid-action
Github Action for converting an output of Terraform graph to Mermaid's syntax.

### [aws](https://github.com/hashicorp/terraform-provider-aws/tree/main/examples/ecs-alb)

```yaml
- uses: asannou/tfmermaid-action@v1
  with:
    exclude: var,output
```
