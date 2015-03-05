<?php
$open = fopen("test.log", "a");
fwrite($open, "REQUEST headers:".implode(",", getallheaders()."\n\rBODY:".http_get_request_body()."\n\r--------------------------------------------\n\r"));
?>