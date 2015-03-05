<?php
class Router
{
    private $ioc;
    private $uri;

    public function __construct($ioc, $uri)
    {
        $this->ioc = $ioc;
        $this->uri = $uri;
    }

    public function validateArgs($action, $actionName, $args)
    {
        $rMethod = new ReflectionMethod($action, $actionName);
        $rParams = $rMethod->getParameters();

        if (count($rParams) !== 0 && count($args) === 0) {
            throw new Exception('Incorrect parameters count', 422);
        }
    }

    public function run()
    {
        $action = new Action($this->ioc);

        $params = explode('/', $this->uri);
        $actionName = $params[0];

        if (!method_exists($action, $actionName)) {
            throw new Exception('Not found', 404);
        }

        unset($params[0]);

        $params = array_values($params);

        $this->validateArgs($action, $actionName, $params);

        $action->$actionName(array_values($params));
    }
}
?>