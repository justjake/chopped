# chopped_nginx Cookbook

My implementation of an NGINX cookbook. My goal is to avoid ever requiring a
consumer of this cookbook to provide a template of their own. I looked at the
existing NGINX cookbooks and they seem pretty lame.

Goals of this cookbook:

- learn how to write LWRPs
- generate clean NGINX config files from ruby data structures
- cover common NGINX use cases with sensible defaults

## TODOs

- refactor libraries/chopped_nginx.rb; it's too big as-is
- make some typical use case templates? model these off what we use at armada.systems
- make sure that the chef run checks each resource as it is declared. right now
  syntax errors can occur without failing the chef run. Maybe we need to handle
  the NGINX service with runit?
- should we just run `nginx -t -c <path to nginx.conf>`?

## Requirements

written and tested on ubuntu 14.04 with Chef 12. Check the Gemfile.lock for this
monorepo for more information.

## Attributes

TODO: List your cookbook attributes here.

e.g.
### chopped_nginx::default

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['chopped_nginx']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### chopped_nginx::default

TODO: Write usage instructions for each cookbook.

e.g.
Just include `chopped_nginx` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[chopped_nginx]"
  ]
}
```
