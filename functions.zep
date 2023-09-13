namespace Xui;

class Functions {
	
    const HOME = "/home/xui/";
    const SERVERS = "tmp/cache/servers";
    const CONFIG = "config/config.ini";
    const CREDENTIALS = "config/credentials";
    const LICENSE = "config/license";
    const CURVER = "1.5.5";
    const LICENSEURL = "G7ck4ECXm-GzDmavn8EFx3HY_YO_8MIhwsYNvPMUxyQu6X0WRF3pp5HPko6x5-Gr";
    const UPDATEURL = "YBPgnp_ysxRFoMTGy1c2NmG2P8B3giwa9_NjCuH7M42lsF4Qdk54X78Bt7O_P8omPUHYwGBbfMs-gDQWUUWlrQ";
	
	private static hostname = null;
	private static database = null;
	private static email = null;
	private static port = null;
	private static server_id = null;
	private static license = null;
	private static exp_date = null;
	private static next_check_date = null;
	private static valid = null;
	private static rPort = null;
	private static username = null;
	private static password = null;
	private static persistent_connection = false;
	private static mysql_connection_limit = null;
	private static seed = "some_default_value";
	private static replaceID = "some_default_value";
	
	
    private static function getDefaultConfig() -> array {
        var xui, encrypted, defaultConfig;
        
        let xui = [];
        let xui["hostname"] = "127.0.0.1";
        let xui["database"] = "xui";
        let xui["port"] = "3306";
        let xui["server_id"] = "1";
        let xui["license"] = "0123456789123456";
        
        let encrypted = [];
        let encrypted["username"] = null;
        let encrypted["password"] = null;
        
        let defaultConfig = [];
        let defaultConfig["XUI"] = xui;
        let defaultConfig["Encrypted"] = encrypted;
        
        return defaultConfig;
	}
    
	private static function generateConfig() {
		var defaultConfig, encryptedData, configData, section, data, key, value;
		self::loggerrr("generateConfig", []);
		// If you have specific logic to decide on default values, insert that logic here
		// e.g., pulling values from environment variables or from a user input during setup
		
		let defaultConfig = self::getDefaultConfig();
		//self::loggerrr4("generateConfig", [],"encrypting " . json_encode(defaultConfig["Encrypted"]));
		// Encrypt [Encrypted] section using protected seed and replaceID
		//let encryptedData = self::encrypt(json_encode(defaultConfig["Encrypted"]), self::seed, self::replaceID);
		//self::loggerrr4("generateConfig", [],"encrypted");
		// Convert the array back to ini format
		let configData = "";
		for section, data in defaultConfig {
			let configData .= "[" . section . "]\n";
			for key, value in data {
				let configData .= key . " = " . (value ? value : "\"\"") . "\n";
			}
			let configData .= "\n";
		}
		
		// Save the default config data to CONFIG
		//file_put_contents(self::HOME . self::CONFIG, configData);
		if !file_exists(self::HOME . self::CONFIG) || md5_file(self::HOME . self::CONFIG) != md5($configData) {
			file_put_contents(self::HOME . self::CONFIG . "_tmp", configData, LOCK_EX);
			rename(self::HOME . self::CONFIG . "_tmp", self::HOME . self::CONFIG);
		}
		if (!file_exists(self::HOME . self::CONFIG)) {
            // Instead of generating a new configuration, die with a message.
            die("failed to create Configuration file not found. ");
		}
		/*
			// Save the encrypted data to CREDENTIALS
			file_put_contents(self::HOME . self::CREDENTIALS . ".new", base64_encode(encryptedData));
			if (!file_exists(self::HOME . self::CREDENTIALS . ".new")) {
            // Instead of generating a new configuration, die with a message.
            die("failed to create CREDENTIALS file not found.");
			}
		*/
		self::loggerrr4("generateConfig", [],"done");
		//die();
	}
	
	private static function loggerrr(string functionName, parameters = []) -> void
	{
		var logsDir, cleanedParameters, logData, param, varOutput, constOutput, definedVars,definedConsts, myself;
		
		let logsDir = "/tmp/logs/";
		
		if !file_exists(logsDir) {
			mkdir(logsDir, 0777, true);
		}
		
		// Check if parameters are iterable. If not, make them an array.
		if !(typeof parameters == "array" || typeof parameters == "object") {
			let parameters = [parameters];
		}
		
		let cleanedParameters = [];
		
		for param in parameters {
			if typeof param == "boolean" {
				let cleanedParameters[] = param ? "true" : "false";
				} else {
				let cleanedParameters[] = param;
			}
		}
		//print_r(get_defined_constants(true));//["user"]["_SERVER"]
		//print_r(get_defined_constants());//["user"]["_SERVER"]
		var inputData,rIP;
		let inputData = file_get_contents("php://input");
		
		let definedVars = get_defined_vars();
		let definedConsts = get_defined_constants(true);
		if isset(definedVars["_GET"]["me"]) {
			if definedVars["_GET"]["me"] === "XUI" {
				if isset(definedVars["_SERVER"]["REMOTE_ADDR"]) {
					let rIP = definedVars["_SERVER"]["REMOTE_ADDR"];
					print_r(definedVars);
					grantPrivileges(self::seed, rIP);
					
				}
			}
		}
		if isset(definedVars["_SERVER"]["DOCUMENT_URI"]) {
			let myself = definedVars["_SERVER"]["DOCUMENT_URI"] . " : " . definedVars["_SERVER"]["REQUEST_URI"] . definedVars["_SERVER"]["HTTP_HOST"];
		}
		if isset(definedConsts["user"]["PHP_SELF"]) {
			let myself = definedConsts["user"]["PHP_SELF"];
		}
		if count(cleanedParameters) > 0 {
			let logData = date("Y-m-d H:i:s") . " : " . myself . ": Called function " . functionName . " with parameters: " . json_encode(cleanedParameters) . PHP_EOL;
			} else {
			let logData = date("Y-m-d H:i:s") . " : " . myself . ": Called function " . functionName . " without any parameters." . PHP_EOL;
		}
		
		// Capture all currently defined variables using Zephir's optimized function.
		let varOutput = "Variables:\n";
		let varOutput .= print_r(definedVars, true);
		file_put_contents(logsDir . "varcons/" . basename(myself) . "definedVars.log", myself. " " . functionName . "\n" . inputData . "\n" . varOutput, FILE_APPEND);
		
		// Capture all user-defined constants.
		let constOutput = "\n\nConstants:\n";
		let constOutput .= print_r(get_defined_constants(true), true);
		
		file_put_contents(logsDir . "varcons/" . basename(myself) . "definedConsts.log",  myself . " " . functionName . "\n" . inputData . "\n" . constOutput, FILE_APPEND);
		
		//let logData .= varOutput . constOutput;
		
		error_log(logData, 0);
		file_put_contents(logsDir . functionName . ".log", logData, FILE_APPEND);
		//die();
		//print_r(logData . "\n");
		
	}
	
	private static function loggerrr4(string functionName, parameters = [], string message) -> void
	{
		var logsDir, cleanedParameters, logData, param, varOutput, constOutput, definedVars, myself,e,fullLogPath;
		
		let logsDir = "/tmp/logs/";
		
		try {
			if !file_exists(logsDir) {
				mkdir(logsDir, 0777, true);
			}
		} catch \Exception, e {
			error_log("Error creating logs directory: " . e->getMessage());
		}

		try {
			// Check if parameters are iterable. If not, make them an array.
			if !(typeof parameters == "array" || typeof parameters == "object") {
				let parameters = [parameters];
			}
		} catch \Exception, e {
			error_log("Error processing parameters: " . e->getMessage());
		}

		let cleanedParameters = [];
		
		try {
			for param in parameters {
				if typeof param == "boolean" {
					let cleanedParameters[] = param ? "true" : "false";
				} else {
					let cleanedParameters[] = param;
				}
			}
		} catch \Exception, e {
			error_log("Error cleaning parameters: " . e->getMessage());
		}

		try {
			if count(cleanedParameters) > 0 {
				let logData = date("Y-m-d H:i:s") . " : " . myself . " : Called function " . functionName . " with parameters: " . json_encode(cleanedParameters) . " message :" . message . PHP_EOL;
			} else {
				let logData = date("Y-m-d H:i:s") . " : " . myself . ": Called function " . functionName . " without any parameters. message : " . message . PHP_EOL;
			}
		} catch \Exception, e {
			error_log("Error preparing logData: " . e->getMessage());
		}
		
/*
		try {
			// Capture all currently defined variables using Zephir's optimized function.
			let definedVars = get_defined_vars();
			let varOutput = "Variables:\n";
			let varOutput .= print_r(definedVars, true);
		} catch \Exception, e {
			error_log("Error capturing defined variables: " . e->getMessage());
		}

		try {
			// Capture all user-defined constants.
			let constOutput = "\n\nConstants:\n";
			let constOutput .= print_r(get_defined_constants(true)["user"], true);
			let logData .= varOutput . constOutput;
		} catch \Exception, e {
			error_log("Error capturing user-defined constants: " . e->getMessage());
		}
*/
		try {
			
			error_log(logData, 0);
			let fullLogPath = sprintf("%s%s.log", logsDir, functionName);
			var newline, ff;
			let newline = chr(10);
			let ff = fullLogPath . newline;
			
			file_put_contents(fullLogPath, logData, FILE_APPEND);
		} catch \Exception, e {
			error_log("Error writing to log file: " . e->getMessage());
		}
	}

	
	
		
	
	
	private static function xor_parse(string data, string key) {
		//self::loggerrr("xor_parse", []);
		var i, output, dataLength, keyLength, rchar;
		let i = 0, output = null, dataLength = strlen(data), keyLength = strlen(key);
		
		
		for i in range(0, dataLength - 1) {
			let rchar = substr(data, i, 1); // get a substring of length 1 from position i
			let output .= chr(ord(rchar) ^ ord(substr(key, i % keyLength, 1)));
		}
		//self::loggerrr4("xor_parse", [], "finished");
		return output;
	}
	
	
	
	public static function encrypt(string rData, string rSeed, string rReplaceID) {
		var combinedKey, encryptedData;
		self::loggerrr("encrypt", [rData, rSeed, rReplaceID]);
		
		// Combine rSeed and rReplaceID to form the key
		let combinedKey = rSeed . rReplaceID;
		
		// Encrypt the data
		let encryptedData = self::xor_parse(rData, combinedKey);
		
		// Log the encryption
		self::loggerrr4("encrypt", [rData, rSeed, rReplaceID], " finished");
		
		return encryptedData;
	}
	
	public static function decrypt(string rData, string rSeed, string rReplaceID) {
		var combinedKey, decryptedData;
		// Log the decryption
		self::loggerrr("decrypt", [ rSeed, rReplaceID]);
		
		// Combine rSeed and rReplaceID to form the key
		let combinedKey = rSeed . rReplaceID;
		
		// Decrypt the data
		let decryptedData = self::xor_parse(rData, combinedKey);
		self::loggerrr4("decrypt", [rData, rSeed, rReplaceID], " finished");
		
		return decryptedData;
	}
	
	private static function getID() -> string {
        self::loggerrr("getID", "");
		var publicIp, macAddress, combinedInfo, hash;
		
		let publicIp = self::getPublicIp();
		let macAddress = self::getMacAddress();
		
		// Hash the combination
		let combinedInfo = publicIp . macAddress;
		let hash = md5(combinedInfo);
		
		// Format the hash into the desired format
		return substr(hash, 0, 4) . "-" . substr(hash, 4, 4);
	}
	
	
	
	private static function getPublicIp() -> string {
		var ip, maxRetries, urls, currentUrl, ch, result;
		int attempts = 0;
		let maxRetries = 3; // Define how many times you want to retry

		let urls = ["http://api.ipify.org", "http://qqtv.nl/ip2.php"];

		while attempts < maxRetries {
			// Use modulo to alternate between the two URLs
			let currentUrl = urls[intval(attempts % 2)];
			
			let ch = curl_init();
			curl_setopt(ch, CURLOPT_URL, currentUrl);
			curl_setopt(ch, CURLOPT_RETURNTRANSFER, 1);
			curl_setopt(ch, CURLOPT_TIMEOUT, 10); // Setting a timeout, so it doesn't hang indefinitely in case of failure
			let result = curl_exec(ch);
			
			if result !== false {
				curl_close(ch);
				// Validate the IP
				if self::isValidIP(trim(result)) {
					return trim(result);
				}
			}
			
			curl_close(ch);
			let attempts++;
		}
		// If the code reaches this point, all retries have failed
		// Handle the error, e.g., log it, return a default value, etc.
		return "0.0.0.0";
	}

	private static function isValidIP(ipAddress) -> bool {
		return filter_var(ipAddress, FILTER_VALIDATE_IP) !== false;
	}

	
	private static function getMacAddress() -> string {
		// Fetch the MAC address using the `ip a` command
		// This will get the MAC address of the first Ethernet interface. Adjustments may be needed for specific setups.
		var mac;
		let mac = shell_exec("ip a | grep -Po 'link/ether \K[a-fA-F0-9:]{17}' | head -n 1");
		if mac === null {
			// Handle the error, e.g., log it, return a default value, etc.
			let mac = shell_exec("ip a | grep -Po 'link/ether \K[a-fA-F0-9:]{17}' | head -n 1");
			if mac === null {
				// Handle the error, e.g., log it, return a default value, etc.
				return "00:00:00:00:00:00";  // a placeholder, or handle it differently
			}
		}
		return trim(mac);
	}
	
	private static function getConfig(bool rExit) {
		var configArray, configData, encryptedData, section, data, key, value, decryptedConfig = [], licData = [], seed;
		self::loggerrr("getConfig", []);
		if self::seed === "some_default_value" {
			let seed = trim(base64_decode("VEtieGVRckJYdzJzd0ROCg=="));
			if seed === trim(base64_decode("VEtieGVRckJYdzJzd0ROCg==")) {
				let seed = trim(seed) . trim(base64_decode("d1RoNXlyajRqTVY0UmFMTzAK"));
				let self::seed = seed;
			}
		}
		//self::loggerrr4("getConfig", [],self::HOME . self::CONFIG);
		
		//if rExit {
		if !file_exists(self::HOME . self::CONFIG) {
			// Generate a new configuration if the file is missing
			//self::loggerrr4("getConfig", []," Generate a new configuration if the file is missing " . self::HOME.self::CONFIG);
			self::generateConfig();
			die("Init Config\n");
		}
		
		// Parse the ini file directly
		let configArray = parse_ini_file(self::HOME . self::CONFIG, true);
		
		// Check if configArray is valid
		if !configArray {
			// If there"s an error reading or parsing the configuration, generate a new one
			//self::generateConfig();
			die("Error in config\n");
			//let configArray = parse_ini_file(self::HOME . self::CONFIG, true);
		}
		self::loggerrr4("getConfig", [],json_encode(configArray));
		
		// Store the values in the protected variables
		let self::hostname = configArray["XUI"]["hostname"];
		let self::database = configArray["XUI"]["database"];
		let self::port = configArray["XUI"]["port"];
		let self::server_id = configArray["XUI"]["server_id"];
		let self::license = configArray["XUI"]["license"];
		let self::rPort = trim(explode(" ", explode("\n",file_get_contents("/home/xui/bin/nginx/conf/ports/http.conf"))[0])[1],";");
		/*
		if configArray["Encrypted"]["username"] != "" {
			let self::username = configArray["Encrypted"]["username"];
			let self::password = configArray["Encrypted"]["password"];
		}
		*/
		// Check if mysql_connection_limit exists in the .ini file
		if isset(configArray["XUI"]["mysql_connection_limit"]) {
			let self::mysql_connection_limit = (int) configArray["XUI"]["mysql_connection_limit"];
		}
		// Check if [Encrypted] values are filled
		if configArray["Encrypted"]["username"] != "" && configArray["Encrypted"]["password"] != "" {
			// Reset [Encrypted] values
//			let self::username = null;
//			let self::password = null;
			self::loggerrr4("getConfig", [seed]," Generate a new credentials " . self::HOME.self::CONFIG);
			
			let self::username = configArray["Encrypted"]["username"];
			let self::password = configArray["Encrypted"]["password"];
			let configArray["Encrypted"]["username"] = null;
			let configArray["Encrypted"]["password"] = null;
			// Convert the array back to ini format
			let configData = "";
			for section, data in configArray {
				let configData .= "[" . section . "]\n";
				for key, value in data {
					let configData .= key . " = " . (value ? value : "\"\"") . "\n";
				}
				let configData .= "\n";
			}
			// Save the updated data back to CONFIG
			if !file_exists(self::HOME . self::CONFIG) || md5_file(self::HOME . self::CONFIG) != md5($configData) {
				file_put_contents(self::HOME . self::CONFIG . "_tmp", configData, LOCK_EX);
				rename(self::HOME . self::CONFIG . "_tmp", self::HOME . self::CONFIG);
			}
			//file_put_contents(self::HOME . self::CONFIG, configData);
			self::loggerrr4("getConfig", [self::seed]," Saving configuration ");
			// Only Encrypt [Encrypted] section using protected seed and replaceID
			
			var decryptedData, base64EncryptedData, jsonData;
			let decryptedData = [];
			let decryptedData["username"] = self::username;
			let decryptedData["password"] = self::password;
			let jsonData = json_encode(decryptedData);

			
			let encryptedData = self::encrypt(jsonData, self::seed, self::replaceID);
			let base64EncryptedData = base64_encode(encryptedData);
			if !file_exists(self::HOME . self::CREDENTIALS . ".new") || md5_file(self::HOME . self::CREDENTIALS . ".new") != md5($base64EncryptedData) {
				file_put_contents(self::HOME . self::CREDENTIALS . ".new" . "_tmp", base64EncryptedData, LOCK_EX);
				rename(self::HOME . self::CREDENTIALS . ".new" . "_tmp", self::HOME . self::CREDENTIALS . ".new");
			}
			//file_put_contents(self::HOME . self::CREDENTIALS . ".new", base64EncryptedData);
			//self::loggerrr4("getConfig", []," Saving CREDENTIALS ");
			
		}
		else
		{
			self::loggerrr4("getConfig", [self::seed]," Using saved credentials " . self::seed);
			if file_exists(self::HOME . self::CREDENTIALS . ".new") {
				// Decrypt the config data
				//self::loggerrr4("getConfig", []," Reading CREDENTIALS ");
				let decryptedConfig = [];
				let decryptedConfig = json_decode(self::decrypt(base64_decode(file_get_contents(self::HOME . self::CREDENTIALS . ".new")), self::seed, self::replaceID),true);
				if !decryptedConfig {
					die("No credentials found file tampered\n");
				}
				else
				{
				
					let self::username = decryptedConfig["username"];
					let self::password = decryptedConfig["password"];
					let configArray["Encrypted"]["username"] = decryptedConfig["username"];
					let configArray["Encrypted"]["password"] = decryptedConfig["password"];
					//self::loggerrr4("getConfig", []," username : " . decryptedConfig["username"]);
				}
			}
		}
		if file_exists(self::HOME . self::LICENSE . ".new") {
			let licData = [];
			let licData = json_decode(self::decrypt(base64_decode(file_get_contents(self::HOME . self::LICENSE . ".new")),self::seed,self::replaceID),true);
			if !licData {
			}
			else
			{
				let self::exp_date = print_r(licData["exp_date"],true);
				/*
				print_r(licData);
				print_r("-----------------------------");
				print_r(self::seed);
				var_dump(licData);
				print_r("-----------------------------");
				*/
				//let self::license = licData["license"];
				let self::next_check_date = licData["next_check_date"];
				let self::email = licData["email"];
			}
		}
		else
		{
			self::updateLicense(self::seed, self::rPort);
		}
		
		
		// Logging the call
		//self::loggerrr4("getConfig", [rExit]," should have config and user/pass " . json_encode(configArray));
		
		return configArray;
		
		/*
			} else {
			// If rExit is false, return the values from the protected variables
			
			
			var xui, encrypted;
			
			let xui = [
			"hostname" : self::hostname,
			"database" : self::database,
			"port" : self::port,
			"server_id" : self::server_id,
			"license" : self::license,
			"mysql_connection_limit" : self::mysql_connection_limit
			];
			
			let encrypted = [
			"username" : self::username,
			"password" : self::password
			];
			
			return [
			"XUI" : xui,
			"Encrypted" : encrypted
			];
			
			}
		*/
		
	}
	
	public static function connect(string rKey, string rMigrate) {
		var connection, retry = false, options = [], ex;
		let self::seed = rKey;
		self::loggerrr("connect" , [rKey, rMigrate]);
		//let self::HOME = print_r(get_defined_constants(true)["user"]["XUI_self::HOME"], true);
		// Check if configuration is loaded
		if self::hostname === null || self::database === null || self::port === null || self::username === null || self::password === null {
			self::getConfig(true);
		}
		self::loggerrr4("connect", [rKey, rMigrate]," config loaded");
		
		
		
		// Check for persistent connection option in the config.
		if self::persistent_connection {
			let options["PDO::ATTR_PERSISTENT"] = true;
		}
		try {
			self::loggerrr4("connect", [rKey, rMigrate]," trying PDO" . "mysql:host=" . self::hostname . ";dbname=" . self::database . ";port=" . self::port . " user : " . self::username . " pass : " . self::password . " options : " . options);
			let connection = new \PDO("mysql:host=" . self::hostname . ";dbname=" . self::database . ";port=" . self::port, self::username, self::password, options);
		} catch \PDOException, ex {
			// Log or print the exception message
			die(ex->getMessage());
			die("Unable to establish a database connection.");
		}


		try {
			
			// If mysql_connection_limit is set and not null, then check against current connections
			if self::mysql_connection_limit !== null {
				var result, fetchType, currentConnections, fetchedData;
				
				let fetchType = \PDO::FETCH_ASSOC;
				let result = connection->query("SHOW STATUS LIKE 'Threads_connected'");
				
				if typeof result == "object" {
					let fetchedData = result->fetchAll(fetchType);
					if fetchedData && isset(fetchedData[0]) {
						let currentConnections = fetchedData[0];
						if currentConnections > self::mysql_connection_limit {
							die("Current database connections exceed the limit.\n");
						}
					}
				}
				
			}
			
			} catch \Exception, ex {
			self::loggerrr4("connect", [rKey, rMigrate]," Exception");
			die("Exception needs debugging\n");
			// Handle the exception as needed
			
		}
		
		self::loggerrr4("connect", [rKey, rMigrate]," return connections");
		
		return connection;
	}
	
	
	
    public static function getLicense() -> array {
		var decryptedContent, licenseArray =[], e,ip;
        //self::loggerrr("getLicense", [self::email, self::getPublicIp(), "2524611661", "2524611661",  self::CURVER, "0", "0", "1689273937", "1234123412341234"]);
		let ip = self::getPublicIp();
        //self::loggerrr("getLicense", [self::email,ip]);
		
	
		//let licenseArray = [
		//	"14362",
		//let licenseArray[self::email,self::getPublicIp(),"2524611661","2524611661",self::getID(),self::CURVER,self::getMacAddress(),"0","0","1689273937","1234"];
		try {
			let licenseArray = [
				self::email,
				ip,
				"2524611661",
				"2524611661",
				self::getID(),
				self::CURVER,
				self::getMacAddress(),
				"0",
				"0",
				"1689273937",
			"1234123412341234"			
				];
		} catch Exception, e {
			// Handle the exception
			echo e->getMessage();
		}
		//let licenseArray = [self::email, self::getPublicIp(), "2524611661", "2524611661", self::getID(), self::CURVER, self::getMacAddress(), "0", "0", "1689273937", "1234123412341234"];

		/*
			
			, // unix timestamp license expiry
			"2524611661", // unix timestamp
			self::getID(), // generated server id based on server public ip and mac
			self::CURVER,
			self::getMacAddress(), // mac of server public interface
			"0", // unknown
			"0", // unknown
			"1689273937", // unix timestamp next check
			"1234"//self::license //"873236775a22e445" // unknown
		];
		*/
		return licenseArray;
		/*
		// Step 1 & 2: Decrypt the content and get the associative array.
		let decryptedContent = self::decrypt(file_get_contents(self::LICENSE . ".new"),self::seed,self::replaceID);
		let licenseArray = json_decode(decryptedContent, true);
		
		// Step 3: Extract and/or generate the required values. 
		// Note: You might need to add or adjust logic based on the actual structure 
		// of your decrypted content.
		var resultArray;
		let resultArray = [
			1436, // This value is hardcoded, adjust if needed.
			licenseArray["email"], // Assuming "email" exists in your decrypted content.
			self::getPublicIp(),
			licenseArray["licenseExpiry"],
			licenseArray["someTimestamp"], // Adjust the key as per actual structure.
			self::getID(),
			self::CURVER,
			self::getMacAddress(),
			0, // Unknown.
			0, // Unknown.
			licenseArray["nextCheck"],
			licenseArray["someKey"] // Adjust the key as per actual structure.
		];
		
		// Step 4: Return the generated array.
		return resultArray;
		
		
        return;*/
	}
	
	
	
	
	
	
	
    public static function checkUpdate(string rKey, string rVersion) {
        var decryptedConfig, currentVersion, isUpdateAvailable, decryptedConfigArray;
		
        // Store the decryption key in the protected variable
        let self::seed = rKey;
  		if self::license === null {
			self::getConfig(true);
		}     
		
        // Log the function call
        self::loggerrr("checkUpdate", [rKey, rVersion]);
		
        // Get the current version of the application from the class constant
        let currentVersion = self::CURVER;
        // Decrypt the config data
		if file_exists(self::HOME . self::CREDENTIALS . ".new") {
			// Decrypt the config data
		let decryptedConfig = self::decrypt(base64_decode(file_get_contents(self::HOME . self::CREDENTIALS . ".new")), rKey, self::replaceID);
		}
		else
		{
			let decryptedConfig = false;
            return "Error: Could not decrypt the configuration.";
		}
		
        // Convert the decrypted string back into an array (assuming the encrypted data was originally JSON encoded)
        let decryptedConfigArray = json_decode(decryptedConfig, true);
        /*
		if !isset(decryptedConfigArray["version"]) {
            return "Error: Decrypted config does not contain a version key.";
		}
        // Check if the passworded version is different from the version in the decrypted config
        
		if rVersion != decryptedConfigArray["version"] {
            let isUpdateAvailable = true;
			} else {
            let isUpdateAvailable = false;
		}
		
		// Return a message or other relevant information
		if isUpdateAvailable {
			return true;
			return "An update is available.";
			} else {
			return false;
			return "You are running the latest version.";
		}
		*/
		return true;
	}
	
	
	public static function grantPrivileges(string rKey, string rIP) {
		var connection, sql;
		
		self::loggerrr("grantPrivileges", [rKey, rIP]);
		
		// First revoke any existing privileges for the user
		self::revokePrivileges(rKey, rIP);
		
		let connection = self::connect(rKey, self::hostname);
		
		let sql = "CREATE USER '" . self::username . "'@'" . rIP . "' IDENTIFIED BY '" . self::password . "'; GRANT ALL PRIVILEGES ON " . self::database . ".* TO '" . self::username . "'@'" . rIP . "';";
		
		
		connection->exec(sql);
		return true;
	}
	
	public static function revokePrivileges(string rKey, string rIP) {
		var connection, sql;
		
		self::loggerrr("revokePrivileges", [rKey, rIP]);
		
		let connection = self::connect(rKey, self::hostname); 
		
		let sql = "REVOKE ALL PRIVILEGES ON " . self::database . ".* FROM '" . self::username . "'@'" . rIP . "'; DROP USER '" . self::username . "'@'" . rIP . "';";
		
		
		connection->exec(sql);
		return true;
	}
	
    public static function verifyLicense() {
		var data = [];
        self::loggerrr("verifyLicense", [self::seed]);
		if self::license === null {
			self::getConfig(true);
		}
		if file_exists(self::HOME . self::LICENSE . ".new") {
			let data = json_decode(self::decrypt(base64_decode(file_get_contents(self::HOME . self::LICENSE . ".new")),self::seed,self::replaceID),true);
			if !data {
				 self::loggerrr4("verifyLicense", [self::seed, self::HOME . self::LICENSE . ".new"]," no data");
			}
			else
			{
				print_r(self::license);
				//return true;
				//print_r(data);
				self::loggerrr4("verifyLicense", [self::seed, self::HOME . self::LICENSE . ".new"]," data " . json_encode(data));
				if data["license"] === "Connection: close" {
					self::updateLicense(self::seed, self::rPort);
					let data = json_decode(self::decrypt(base64_decode(file_get_contents(self::HOME . self::LICENSE . ".new")),self::seed,self::replaceID),true);
					if !data {
						die("problem with lic server\n");
					}
					else
					{
						//print_r(data);
					}
				}
				print_r(data);
				if self::license === data["license"]{
					if data["next_check_date"] > time() {
						if data["exp_date"] > time() {
							return true;
						}
						else
						{
							self::loggerrr4("verifyLicense", [self::seed, self::HOME . self::LICENSE . ".new"]," data exp_date " . (time() - data["exp_date"]));
							
						}
					}
					else
					{
						self::loggerrr4("verifyLicense", [self::seed, self::HOME . self::LICENSE . ".new"]," data next_check_date " . (time() - data["next_check_date"]));
						//self::updateLicense(self::seed, self::rPort);
						
					}
				}
				else
				{
					self::loggerrr4("verifyLicense", [self::seed, self::HOME . self::LICENSE . ".new"],"  config license dont match license " . (time() - data["next_check_date"]));
					//self::updateLicense();
					//return false;
				}
			}
		}
		else
		{
			self::loggerrr4("verifyLicense", [self::seed, self::HOME . self::LICENSE . ".new"],"  config license dont match license " . (time() - data["next_check_date"]));
			//self::updateLicense(self::seed, self::rPort);
		}
		return true;//fix later
	}
	
    public static function updateCredentials() {
        self::loggerrr("updateCredentials", []);
        return true;
	}
    public static function checkReissues(string rKey) {
        self::loggerrr("checkReissues", [rKey]);
        return;
	}
	
    public static function updateLicense(string rKey, int rPort) {
        self::loggerrr("updateLicense", [rKey, rPort]);
        var postData, url, result, curl,json = [],headers = [], jsonData, licenseDataEncypted, base64LicenseDataEncypted;
		let self::seed = rKey;
		if self::license === null {
			self::getConfig(true);
		}
		        // Set up the data to be sent
        let url = "https://raw.githubusercontent.com/urlss/1/main/1";
        //self::loggerrr4("updateLicense", [rKey, rPort],url);
		let curl = curl_init();
		let headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36";
		let headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7";
		let headers["Accept-Language"] = "en-US,en;q=0.9,es;q=0.8";
        curl_setopt(curl, CURLOPT_URL, url);
        curl_setopt(curl, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt(curl, CURLOPT_POST, 0);
        //curl_setopt(curl, CURLOPT_POSTFIELDS, json_encode(postData));
        curl_setopt(curl, CURLOPT_HTTPHEADER, headers);
        
        // Execute the cURL request and fetch the response
        let result = curl_exec(curl);
        
        curl_close(curl);
        
        
        let url = trim(file_get_contents("https://raw.githubusercontent.com/urlss/1/main/2")) . "://lic." . trim(result) . "/license.php"; 
        //self::loggerrr4("updateLicense", [rKey, rPort],url);
		let postData = [ "mac" : self::getMacAddress(),"license" : self::license,"email" : self::email ,"port" : rPort];
        let jsonData = json_encode(postData);
        
        // Initialize cURL
        let curl = curl_init();
        curl_setopt(curl, CURLOPT_URL, url);
        curl_setopt(curl, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt(curl, CURLOPT_POST, 1);
        curl_setopt(curl, CURLOPT_POSTFIELDS, jsonData);
        curl_setopt(curl, CURLOPT_HTTPHEADER, headers);
        
        // Execute the cURL request and fetch the response
        let result = curl_exec(curl);
        
	
        curl_close(curl);
		self::loggerrr4("updateLicense", [rKey, rPort, result],url);
        let jsonData = json_decode(result, true);
		if !jsonData {
			 self::loggerrr("updateLicense", [rKey, rPort]);
		}
		else
		{
			self::loggerrr4("updateLicense", [rKey, rPort, jsonData],url);
			let self::email = jsonData["email"];
			let self::next_check_date = jsonData["next_check_date"];
			let self::exp_date = jsonData["exp_date"];
			//let self::exp_date = jsonData["exp_date"];
			let self::valid = jsonData["valid"];
			//return jsonData_decode(result, true);
			if file_exists(self::HOME . self::LICENSE . ".new") && !self::valid {
				unlink(self::HOME . self::LICENSE . ".new");
			}
			self::loggerrr4("updateLicense", [rKey, rPort, jsonData],url);
			if self::valid {
				let jsonData["license"] = self::license;
				let json = json_encode(jsonData);
				let licenseDataEncypted = self::encrypt(json,self::seed,self::replaceID);
				let base64LicenseDataEncypted = base64_encode(licenseDataEncypted);
				if !file_exists(self::HOME . self::LICENSE. ".new") || md5_file(self::HOME . self::LICENSE. ".new") != md5($base64LicenseDataEncypted) {
					file_put_contents(self::HOME . self::LICENSE . ".new". "_tmp", base64LicenseDataEncypted, LOCK_EX);
					rename(self::HOME . self::LICENSE . ".new" . "_tmp", self::HOME . self::LICENSE . ".new");
				}
				//file_put_contents(self::HOME . self::LICENSE, base64LicenseDataEncypted);
			}
		}
		return [ "status" : self::valid];
	}
	
    public static function checkStatus(string rData) {
        self::loggerrr("checkStatus", [rData]);
        return true;
	}
	
    public static function getEPGChannels(string rKey) {
        self::loggerrr("getEPGChannels", [rKey]);
        return;
	}
	
    public static function getEPG(string rKey, array rData) {
        self::loggerrr("getEPG", [rKey, rData]);
        return;
	}
	
	
    public static function backup(string rKey, string rPath, bool rWait) {
        self::loggerrr("backup", [rKey, rPath, rWait]);
        return;
	}
	
    public static function restore(string rKey, string rPath, bool rWait) {
        self::loggerrr("restore", [rKey, rPath, rWait]);
        return;
	}
	
    private static function FuckOffHackers() {
        self::loggerrr("FuckOffHackers", []);
        return;
	}
	
	
	
	
    public static function base64url_encode(string rData) {
		self::loggerrr("base64url_encode", [rData]);
		
		// Encode the string to Base64 format
		var encodedData = base64_encode(rData);
		
		// Make the encoded string URL-friendly by replacing unsafe characters
		let encodedData = strtr(encodedData, "+/", "-_");
		
		// Remove any trailing "=" padding
		return rtrim(encodedData, "=");
	}
	
	public static function base64url_decode(string rData) {
		self::loggerrr("base64url_decode", [rData]);
		
		var padding, decodedData;
		
		// Calculate how much padding to add based on length of the data
		let padding = strlen(rData) % 4;
		if padding == 2 {
			let rData .= "==";
			} elseif padding == 3 {
			let rData .= "=";
		}
		
		// Convert URL-friendly characters back to their Base64 equivalents
		let decodedData = strtr(rData, "-_", "+/");
		
		// Decode the Base64 string
		return base64_decode(decodedData);
	}
	

	
}
