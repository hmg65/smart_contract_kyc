pragma solidity ^ 0.5.1;

//Author - Hemant Gupta

/**
 * @title Digital Identity - KYC/AML
 * Ethereum Contract for KYC Verification
 */


contract kyc {

    /**
     * Structure for KYC fields to submit
     */

    struct kycd {
        string name;
        string adress;
        string aadhar;
        string pan;
        string status;
    }

    // User's ethereum address is treated as Account ID in the contract   

    /** mapping the user address to struct kyc.kycd */
    mapping(address => kycd) public kycdetails;

    /** mapping the user address to boolean
     * Boolean : True [if user has submitted the KYC]
     */
    mapping(address => bool) public check;

    /**mapping the input address to boolean 
     * Boolean : True [if address is assigned as KYC Approver address]
     */
    mapping(address => bool) public isapprover;

    /**
     * constructor of the contract kyc
     * @param _approver KYC Approver Address
     */
    constructor(address _approver) public {
        isapprover[_approver] = true;

    }

    /**
     * Validates Aadhar number.
     * @param _aadhar Aadhar card number.
     * @return flag Tells that Aadhar card number is valid or not.
     */

    function validate_aadhar(string memory _aadhar) public pure returns(bool flag) {
        string memory aadhar = _aadhar;
        bytes memory a_length = bytes(aadhar);
        if (a_length.length < 12 || a_length.length > 12) {
            return false;
        } else {
            return true;
        }

    }

    /**
     * Validates PAN number.
     * @param _pan PAN card number.
     * @return flag Tells that PAN card number is valid or not.
     */

    function validate_pan(string memory _pan) public pure returns(bool flag) {
        string memory pan = _pan;
        bytes memory pan_length = bytes(pan);
        if (pan_length.length < 10 || pan_length.length > 10) {
            return false;
        } else {
            return true;
        }

    }

    /** 
     * Function to upload the KYC details for verification
     * @param _name Name of the Person
     * @param _adress Residential Address
     * @param _aadhar 12 Digit Aadhar Number
     * @param _pan PAN Number
     */

    function upload(string memory _name, string memory _adress, string memory _aadhar, string memory _pan)
    public {

        /** Statement to deny the access of upload function to KYC Approver Address. */
        require(!isapprover[msg.sender], "Access Denied");

        /** Statement to check whether the user has already submitted the details or not. */

        require(!check[msg.sender], "KYC already completed for this Account ID.");

        string memory name = _name;
        string memory pan = _pan;
        string memory aadhar = _aadhar;
        string memory adress = _adress;
        string memory status = "Unverified";

        require(validate_aadhar(aadhar), "Invalid Aadhar Number");
        require(validate_pan(pan), "Invalid PAN Number");

        kycd memory Kycd = kycd(name, adress, aadhar, pan, status);
        kycdetails[msg.sender] = Kycd;
        check[msg.sender] = true;

    }


    /**
     * Function for approver to verify & approve the KYC details of entered Account ID
     * @param isvalid for specifying whether KYC data is valid or not
     * @param id KYC Approver Address
     */

    function verify(string memory isvalid, address id) public {

        /** Statement to ensure the present address is KYC Approver address only */

        require(isapprover[msg.sender], "Access Denied");
        kycd memory Kycd = kycdetails[id];
        string memory y = "Y";

        /**comparing the arguement {valid} to "Y"
         * if true then assigning status as "Verified" to {id}
         */
        if (keccak256(abi.encodePacked((isvalid))) == keccak256(abi.encodePacked((y)))) {
            Kycd.status = "Verified";
        } else {
            Kycd.status = "Verification Failed. Please re-apply after submitting correct information.";
        }

        kycdetails[id] = Kycd;

    }

    /**
     * Function that allows user to modify his KYC details
     */

    function modify(string memory _name, string memory _adress, string memory _aadhar, string memory _pan)
    public {
        require(check[msg.sender], "Please submit the KYC first.");
        check[msg.sender] = false;


        string memory name = _name;
        string memory pan = _pan;
        string memory adress = _adress;
        string memory aadhar = _aadhar;

        // using upload function to modify the KYC data    
        upload(name, adress, aadhar, pan);

    }

}