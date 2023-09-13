<?php

// Report all PHP errors
error_reporting(E_ALL);

// Display errors in the output
ini_set('display_errors', 1);

// Display startup errors
ini_set('display_startup_errors', 1);
#include 'init.php';die();
define("XUI_HOME","/home/xui/");

//include '/home/xui/includes/xui.php';
//require str_replace('\\', '/', dirname($argv[0])) . '/stream/init.php';
require '/home/xui/www/stream/init.php';
ini_set('display_startup_errors', 1);
ini_set('display_errors', 1);
ini_set('memory_limit', -1);
error_reporting(E_ALL);

echo "Current Memory Usage: " . memory_get_usage() . " bytes";
echo "Current Memory Usage (with PHP's overhead): " . memory_get_usage(true) . " bytes";
echo "Peak Memory Usage: " . memory_get_peak_usage() . " bytes";
echo "Peak Memory Usage (with PHP's overhead): " . memory_get_peak_usage(true) . " bytes";
echo "PHP Memory Limit: " . ini_get('memory_limit');
$meminfo = file_get_contents("/proc/meminfo");
preg_match("/MemAvailable:\s+(\d+) kB/", $meminfo, $matches);
echo "Available System Memory: " . $matches[1] . " kB";

echo "\n---\nconnect\n";
if (!Xui\Functions::connect("TKbxeQrBXw2swDNwTh5yrj4jMV4RaLO0","")) echo " false\n";
else echo " true\n";
//die();



// Print File Inclusions
echo "\nIncluded Files:\n";
$includedFiles = get_included_files();
foreach ($includedFiles as $file) {
    echo $file . "\n";
}


// Print classes
echo "\nClasses:\n";
$definedClasses = get_declared_classes();
foreach ($definedClasses as $className) {
    $reflectionClass = new ReflectionClass($className);
    if ($reflectionClass->isUserDefined()) {  // Only user-defined classes
        echo "Class name: " . $reflectionClass->getName() . "\n";
        
        echo "Methods:\n";
        foreach ($reflectionClass->getMethods() as $method) {
            echo "- " . $method->name . "\n";
        }
        
        echo "Properties:\n";
        foreach ($reflectionClass->getProperties() as $property) {
            echo "- " . $property->name . " (" . ($property->isPublic() ? "public" : ($property->isProtected() ? "protected" : "private")) . ")\n";
        }
        
        echo "-----------------------------\n";
    }
}

// Print all variables
echo "Variables:\n"; print_r(get_defined_vars());

// Print all constants
echo "\n\nConstants:\n"; print_r(get_defined_constants(true)["user"]); // Only user-defined constants

// Print all functions
echo "\n\nFunctions:\n"; print_r(get_defined_functions()["user"]); // Only user-defined functions
try {
    $class = new ReflectionClass('Xui\Functions');

    // Class details
    echo "Class Name: " . $class->getName() . "\n";
    echo "Namespace: " . $class->getNamespaceName() . "\n";
    echo "Is Abstract: " . ($class->isAbstract() ? "Yes" : "No") . "\n";
    echo "Is Final: " . ($class->isFinal() ? "Yes" : "No") . "\n";
    echo "Is Interface: " . ($class->isInterface() ? "Yes" : "No") . "\n";
    echo "Is Trait: " . ($class->isTrait() ? "Yes" : "No") . "\n";

} catch (ReflectionException $e) {
    echo "Error fetching class details: " . $e->getMessage();
}

try {
    // Constructor
    $constructor = $class->getConstructor();
    if ($constructor) {
        echo "\nConstructor: " . $constructor->getName() . "\n";
        foreach ($constructor->getParameters() as $param) {
            echo "- Parameter: " . $param->getName() . "\n";
        }
    }
} catch (ReflectionException $e) {
    echo "Error fetching constructor details: " . $e->getMessage();
}

try {
    // Methods
    echo "\nMethods:\n";
    $methods = $class->getMethods();
    foreach ($methods as $method) {
        echo "- Method Name: " . $method->getName() . "\n";
        echo "  Visibility: " . ($method->isPublic() ? 'public' : ($method->isProtected() ? 'protected' : 'private')) . "\n";
        
        // Parameters
        foreach ($method->getParameters() as $param) {
            echo "  - Parameter: " . $param->getName();
            if ($param->hasType()) {
                echo " Type: " . $param->getType();
            }
            echo "\n";
        }
    }
} catch (ReflectionException $e) {
    echo "Error fetching method details: " . $e->getMessage();
}

try {
    // Properties
    echo "\nProperties:\n";
    $properties = $class->getProperties();
    foreach ($properties as $property) {
        echo "- Property Name: " . $property->getName() . "\n";
        echo "  Visibility: " . ($property->isPublic() ? 'public' : ($property->isProtected() ? 'protected' : 'private')) . "\n";
    }
} catch (ReflectionException $e) {
    echo "Error fetching property details: " . $e->getMessage();
}

try {
    // Constants
    echo "\nConstants:\n";
    $constants = $class->getConstants();
    foreach ($constants as $constName => $constValue) {
        echo "$constName = $constValue\n";
    }
} catch (ReflectionException $e) {
    echo "Error fetching constant details: " . $e->getMessage();
}

try {
    // Traits
    echo "\nTraits:\n";
    $traits = $class->getTraits();
    foreach ($traits as $trait) {
        echo $trait->getName() . "\n";
    }
} catch (ReflectionException $e) {
    echo "Error fetching trait details: " . $e->getMessage();
}

try {
    // Interfaces
    echo "\nImplements Interfaces:\n";
    $interfaces = $class->getInterfaces();
    foreach ($interfaces as $interface) {
        echo $interface->getName() . "\n";
    }
} catch (ReflectionException $e) {
    echo "Error fetching interface details: " . $e->getMessage();
}

try {
    // Parent class
    if ($parent = $class->getParentClass()) {
        echo "\nParent Class:\n" . $parent->getName() . "\n";
    }
} catch (ReflectionException $e) {
    echo "Error fetching parent class details: " . $e->getMessage();
}
echo "\n\n---\n\n";

$object = new Xui\Functions();

$reflection = new ReflectionClass($object);
$method = $reflection->getMethod('getID');
$method->setAccessible(true);

echo "\n---\ngetID\n";
echo $method->invoke($object);
//print_r(Xui\Functions::getID());
//print_r(Xui\Functions::verifyLicense());

echo "\n---\ngetLicense\n";

$licenseData = Xui\Functions::getLicense();

foreach ($licenseData as $key => $value) {
    echo "Key: $key, Value: $value<br>\n";
}

echo "\ncheckUpdate\n";
print_r(Xui\Functions::checkUpdate("TKbxeQrBXw2swDNwTh5yrj4jMV4RaLO0", '1.5.5'));
/*returns
*/
//print_r(Xui\Functions::checkUpdate('TKbxeQrBXw2swDNwTh5yrj4jMV4RaLO0', XUI_VERSION));
echo "\ncheckReissues\n";
print_r(Xui\Functions::checkReissues("TKbxeQrBXw2swDNwTh5yrj4jMV4RaLO0"));

//print_r(Xui\Functions::getID());
//print_r(Xui\Functions::checkStatus());
// Report all PHP errors
error_reporting(E_ALL);

// Display errors in the output
ini_set('display_errors', 1);

// Display startup errors
ini_set('display_startup_errors', 1);


echo "\n---\nverifyLicense\n";

if (Xui\Functions::verifyLicense()) echo "true\n";
else echo "false\n";

//print_r(Xui\Functions::verifyLicense());
echo "Current Memory Usage: " . memory_get_usage() . " bytes";
echo "Current Memory Usage (with PHP's overhead): " . memory_get_usage(true) . " bytes";
echo "Peak Memory Usage: " . memory_get_peak_usage() . " bytes";
echo "Peak Memory Usage (with PHP's overhead): " . memory_get_peak_usage(true) . " bytes";
echo "PHP Memory Limit: " . ini_get('memory_limit');
$meminfo = file_get_contents("/proc/meminfo");
preg_match("/MemAvailable:\s+(\d+) kB/", $meminfo, $matches);
echo "Available System Memory: " . $matches[1] . " kB";

echo "\n---\nconnect\n";
if (!Xui\Functions::connect("TKbxeQrBXw2swDNwTh5yrj4jMV4RaLO0","")) echo " false\n";
else echo " true\n";

echo "\ngetLicense\n";
print_r(Xui\Functions::getLicense());

echo "\nupdateCredentials\n";
print_r(Xui\Functions::updateCredentials());
echo "\nupdatetLicense\n";
Xui\Functions::updateLicense("TKbxeQrBXw2swDNwTh5yrj4jMV4RaLO0",888);
echo "\ngettLicense\n";
$lic = Xui\Functions::getLicense();
print_r($lic);
echo "\nconnect\n";
$dbh = Xui\Functions::connect("TKbxeQrBXw2swDNwTh5yrj4jMV4RaLO0", "");
