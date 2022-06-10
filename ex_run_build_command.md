###

```bash
DOCKER_BUILDKIT=1 docker build -t osticket:1.16.3 .
```
###
here is the solution. open "/include/pear/NET/SMTP.php" and replace to this

```bash
// Turn off peer name verification by default
if (!$socket_options)
$socket_options = array(
'ssl' => array(
'verify_peer' => false,
'verify_peer_name' => false,
'allow_self_signed' => true
)
);

```bash


