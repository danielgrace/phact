<?php

class ResultsFilter {

	/**
	 * @var singleton instance of class
	 */
	private static $instance = null;

	private $filtersArray = array();

	function __construct() {

	}

	/**
	 * Returns an singleton instance of this class
	 *
	 * @return
	 */
	public static function getInstance() {

		if (self::$instance == null) {
			self::$instance = new ResultsFilter();
		}
		return self::$instance;
	}

	public function addFilter($functionName) {
		$this -> filtersArray[] = $functionName;
	}

	/**
	 * Gets array of results. Each results is a single array with the following elements:
	 * filter, title, description
	 */
	public function filterResult($resultsArray) {
		$finalResult = array();
		$filterCount = count($this -> filtersArray);
		foreach ($resultsArray as $key => $result) {
			$passed = 0;
			if ($filterCount > 0) {
				while ($passed < $filterCount &&  $result = call_user_func($this -> filtersArray[$passed], $result)) {
					++$passed;
				}
				if ($passed == $filterCount) {
					$finalResult[] = $result;
				} 
                
			}
		}
		
		if(empty($finalResult)){
			$finalResult[] = $resultsArray[0];
		}
		
		return $finalResult;
	}

}

require_once dirname(__FILE__) . "/filters.php";
?>