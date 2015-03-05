<?php

/**
 * Filters the string that contains ellipsis in text
 *
 * Example of a string:
 * Some sentence that is not finished ... another sentence ...
 * After Filtering:
 * Some sentence that is not finished. Another sentence.
 */
function filterEllipsis($result) {
    $description = $result['description'];

    $pattern = '/\s?\.{2,}\s?/';
    preg_match_all($pattern, $description, $matches, PREG_OFFSET_CAPTURE);
    foreach ($matches[0] as $key => $match) {
        $ellipsisString = $match[0];
        $position = $match[1];
        $string = ucfirst(trim(substr($description, $position + strlen($ellipsisString))));
        $description = substr($description, 0, $position + strlen($ellipsisString)) . " " . $string;
    }

    $result['description'] = preg_replace($pattern, ".", $description);
    return $result;
}

/**
 * Filters the string that contains new line symbols('\n') and removes them
 *
 * Example of a string:
 * Some sentence \nthat contains a new line \nsymbols.
 * After Filtering:
 * Some sentence that contains a new line symbols.
 */
function filterNewLineSymbols($result) {
    $result['description'] = str_replace("\n", "", $result['description']);
    return $result;
}

/**
 * Filters the string that contains new line symbols('\n') and removes them
 *
 * Example of a string:
 * Some sentence \nthat contains a new line \nsymbols.
 * After Filtering:
 * Some sentence that contains a new line symbols.
 */
function filterNonEnglishSymbols($result) {
    $result['description'] = preg_replace('/[^0-9a-zA-Z\.\,\s]+/', '', $result['description']);
    return $result;
}

/**
 * Filters the string that finishes without a point at the end, and removes characters from the end until reaches a point
 *
 * Example of a string:
 * Some sentence that is finished. Another sentence that is not completely finished and there is no a point at the end
 * After Filtering:
 * Some sentence that is finished.
 */
function endWithPoint($result) {
    $description = $result['description'];
    $positionOfLastPoint = strrpos($description, ".");
    $positionOfLastEllipsis = strrpos($description, "...");
    $position = $positionOfLastPoint > $positionOfLastEllipsis ? $positionOfLastPoint : $positionOfLastEllipsis;
    $result['description'] = substr($description, 0, $position + 1);
    return $result;
}

/**
 * Checks if string is not longer than 256 chars and not shorter than 200 chars
 */
function checkSymbolCount($result){
    $result_length = 0;
    $description = $result['description'];
    if(strlen($description) < 200) {
        return false;
    }
    else if(strlen($description) < 256) {
        $result_length = strrpos($description, " ") - 1;
    }
    else {
        $result_length = 256;
    }
    $result['description'] = substr($description, 0, strpos($description, " ", $result_length));
    return $result;
}


$resultsFilter = ResultsFilter::getInstance();
$resultsFilter->addFilter("filterEllipsis");
$resultsFilter->addFilter("filterNewLineSymbols");
$resultsFilter->addFilter("filterNonEnglishSymbols");
$resultsFilter->addFilter("checkSymbolCount");
$resultsFilter->addFilter("endWithPoint");
?>