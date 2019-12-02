pragma solidity ^0.5.11;

contract administrated {
    address public admin;

    constructor() public{
        admin = msg.sender;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "You can't use the function, you aren't admin");
        _;
    }

    function transferAdminRole(address newAdmin) public onlyAdmin {
        admin = newAdmin;
    }
}

contract cityHall is administrated {

    // STRUCT & DATA

    struct Person {
        string firstname;
        string lastname;
        string sexe;
        bool exist;
    }

    struct BirthCertificate {
        uint256 birthDate;
        string birthPlace;
        address[] parents;
        bool exist;
    }

    struct WeddingContract {
        address husbandAddress;
        address wifeAddress;
        uint256 weddingDate;
        bool active;
    }

    struct DeathCertificate {
        uint256 deathDate;
        string deathPlace;
        bool exist;
    }

    mapping(address => Person) private persons;
    mapping(address => BirthCertificate) private birthCertificates;
    mapping(address => WeddingContract[]) private weddingContracts;
    mapping(address => DeathCertificate) private deathCertificates;

    // PERSON ACTIONS

    /**
     * Default function to create a Person.
     * We have to have the person and birth certificates datas
     *
     * @param _personAddress    : Person address
     * @param _firstname        : Person firstname
     * @param _lastname         : Person lastname
     * @param _birthDate        : Person birth date in timestamp
     * @param _birthPlace       : Person birth place
     * @param _parents          : List of parent's adresses
     *
     * @return success
     */

    function newPerson(address _personAddress, string memory _firstname, string memory _lastname,
        string memory _sexe, uint256 _birthDate, string memory _birthPlace, address[] memory _parents) public onlyAdmin  returns(bool success) {
        // Check if the person or the contract already exist
        require(!persons[_personAddress].exist, "The person already exist");
        require(!birthCertificates[_personAddress].exist, "The person have already a birth contract");

        // Create the person and add it into the mapping
        persons[_personAddress] = Person({
            firstname: _firstname,
            lastname: _lastname,
            sexe: _sexe,
            exist: true
        });

        // Create the birth cretificate and add it into the mapping
        birthCertificates[_personAddress] = BirthCertificate({
            birthDate: _birthDate,
            birthPlace: _birthPlace,
            parents: _parents,
            exist: true
        });

        return true;
    }

    /**
     * Special case function to create a Person.
     * Just the person datas, and not the birth certificate datas, are required
     *
     * @param _personAddress    : Person address
     * @param _firstname        : Person firstname
     * @param _lastname         : Person lastname
     *
     * @return success
     *
     */

    function newPersonWithoutBirthCertificate(address _personAddress, string memory _firstname,
    string memory _lastname, string memory _sexe) public onlyAdmin returns(bool success) {

        // Check if the person or the contract already exist
        require(!persons[_personAddress].exist, "The person already exist");

        // Create the person and add it into the mapping
        persons[_personAddress] = Person({
            firstname: _firstname,
            lastname: _lastname,
            sexe: _sexe,
            exist: true
        });

        return true;
    }

    /**
     * Get person data of specific person
     *
     * @param _personAddress    : Person address
     *
     * @return string, string, string
     */

   function getSpecificPerson(address _personAddress) public onlyAdmin view returns(string memory, string memory, string memory) {

       // Check if the person exist or the certificate exist
       require(persons[_personAddress].exist, "The person doesn't exist");

       return (persons[_personAddress].firstname, persons[_personAddress].lastname, persons[_personAddress].sexe);
   }

   /**
     * Get person data of the sender
     *
     * @return string, string
     */

   function getPerson() public view returns(string memory, string memory, string memory) {

       // Check if the person exist or the certificate exist
       require(persons[msg.sender].exist, "The person doesn't exist");

       return (persons[msg.sender].firstname, persons[msg.sender].lastname, persons[msg.sender].sexe);
   }


    // BIRTH CERTIFICATE ACTIONS

    /**
     * Add the birth certificate for a person
     * We have to have the person and birth certificates datas
     *
     * @param _personAddress    : Person address
     * @param _birthDate        : Person birth date in timestamp
     * @param _birthPlace       : Person birth place
     * @param _parents          : List of parent's adresses
     *
     * @return success
     */

    function addBirthCertificate(address _personAddress, string memory _birthPlace,
     uint256 _birthDate, address[] memory _parents) public onlyAdmin returns(bool success) {

        // Check if the person exist and that the contract don't already exist
        require(persons[_personAddress].exist, "The person doesn't exist, please add the person before");
        require(!birthCertificates[_personAddress].exist, "The person have already a birth contract");


        // Create the birth cretificate and add it into the mapping
        birthCertificates[_personAddress] = BirthCertificate({
            birthDate: _birthDate,
            birthPlace: _birthPlace,
            parents: _parents,
            exist: true
        });

        return true;
    }

    /**
     * Get birth certificate of specific person
     *
     * @param _personAddress    : Person address
     *
     * @return uint256, string, address[]
     */

   function getSpecificBirthCertificate(address _personAddress) public onlyAdmin view returns(uint256, string memory, address[] memory) {

       // Check if the person exist or the certificate exist
       require(persons[_personAddress].exist, "The person doesn't exist");
       require(birthCertificates[_personAddress].exist, "The certificate doesn't exist");

       return (birthCertificates[_personAddress].birthDate,
                birthCertificates[_personAddress].birthPlace,
                birthCertificates[_personAddress].parents);
   }

   /**
     * Get birth certificate of the sender
     *
     * @return uint256, string, address[]
     */

   function getBirthCertificate() public view returns(uint256, string memory, address[] memory) {

       // Check if the person exist or the certificate exist
       require(persons[msg.sender].exist, "The person doesn't exist");
       require(birthCertificates[msg.sender].exist, "The certificate doesn't exist");

       return (birthCertificates[msg.sender].birthDate, birthCertificates[msg.sender].birthPlace, birthCertificates[msg.sender].parents);
   }

    // WEDDING CERTIFICATE ACTIONS

    /**
     * Add a new wedding contract
     *
     * @param _husbandAddress   : Husband address
     * @param _wifeAddress      : Wife address
     * @param _weddingDate      : Wedding data
     *
     * @return success
     */

    function addWeddingContract(address _husbandAddress, address _wifeAddress, uint256 _weddingDate) public onlyAdmin returns(bool success) {


        // Husband and wife have to be in the map to create the wedding certificate
        require(persons[_husbandAddress].exist && persons[_wifeAddress].exist, "The husband or the wife isn't in our data-system");

        // Check if the husband or the wife isn't already married
        WeddingContract[] memory husbandContracts = weddingContracts[_husbandAddress];
        uint husbandContractLength = husbandContracts.length;
        for (uint i = 0; i < husbandContractLength; i++) {
            require(!husbandContracts[i].active, "The husband is already married");
            require(husbandContracts[i].husbandAddress != _husbandAddress && husbandContracts[i].wifeAddress != _wifeAddress,
            "They are already married between them");
        }

        WeddingContract[] memory wifeContracts = weddingContracts[_wifeAddress];
        uint wifeContractLength = wifeContracts.length;
        for (uint i = 0; i < wifeContractLength; i++) {
            require(!wifeContracts[i].active, "The wife is already married");
        }

        // Create the certificate and add it on both
        WeddingContract memory weddingContract = WeddingContract({
            husbandAddress: _husbandAddress,
            wifeAddress: _wifeAddress,
            weddingDate: _weddingDate,
            active: true
        });

        weddingContracts[_husbandAddress].push(weddingContract);
        weddingContracts[_wifeAddress].push(weddingContract);

        return true;
    }

    /**
     * Get wedding contracts of specific person
     *
     * @param _personAddress    : Person address
     *
     * @return address[], address[], uint256[]
     */

   function getSpecificWeddingContracts(address _personAddress) public onlyAdmin view
            returns(address[] memory, address[] memory, uint256[] memory) {

       // Check if the person exist or the certificate exist
       require(persons[_personAddress].exist, "The person doesn't exist");
       require(weddingContracts[_personAddress].length == 0, "No wedding contracts");

       address[] memory husbandAddresses = new address[](weddingContracts[_personAddress].length);
       address[] memory wifeAddresses = new address[](weddingContracts[_personAddress].length);
       uint256[] memory weddingDates = new uint256[](weddingContracts[_personAddress].length);

       for (uint i = 0; i < weddingContracts[_personAddress].length; i++) {
            husbandAddresses[i] = weddingContracts[_personAddress][i].husbandAddress;
            wifeAddresses[i] = weddingContracts[_personAddress][i].wifeAddress;
            weddingDates[i] = weddingContracts[_personAddress][i].weddingDate;
        }

       return (husbandAddresses, wifeAddresses, weddingDates);
   }

   /**
     * Get wedding contracts of the sender
     *
     * @return address[], address[], uint256[]
     */

   function getWeddingContracts() public view returns(address[] memory, address[] memory, uint256[] memory) {

       // Check if the person exist or the certificate exist
       require(persons[msg.sender].exist, "The person doesn't exist");
       require(weddingContracts[msg.sender].length == 0, "No wedding contracts");

       address[] memory husbandAddresses = new address[](weddingContracts[msg.sender].length);
       address[] memory wifeAddresses = new address[](weddingContracts[msg.sender].length);
       uint256[] memory weddingDates = new uint256[](weddingContracts[msg.sender].length);

       for (uint i = 0; i < weddingContracts[msg.sender].length; i++) {
            husbandAddresses[i] = weddingContracts[msg.sender][i].husbandAddress;
            wifeAddresses[i] = weddingContracts[msg.sender][i].wifeAddress;
            weddingDates[i] = weddingContracts[msg.sender][i].weddingDate;
        }

       return (husbandAddresses, wifeAddresses, weddingDates);
   }


    // DEATH CERTIFICATE ACTIONS

    /**
     * Add a new death contract
     *
     * @param _personAddress    : Person address
     * @param _deathDate        : Date of the death
     * @param _deathPlace       : Death place
     *
     * @return success
     */

   function addDeathCertificate(address _personAddress, uint256 _deathDate, string memory _deathPlace) public onlyAdmin returns(bool success) {

       // Check if the person exist or the certificate already exist
       require(persons[_personAddress].exist, "The person doesn't exist, please add the person before");
       require(deathCertificates[_personAddress].exist, "The death certificate already exist for this person");

       // Check if the date of the birth certificate isn't superior than the date of the death certificate
       require(birthCertificates[_personAddress].birthDate <= _deathDate,
       "The date of the birth certificate is superior than the death certificate");

       // Create the birth cretificate and add it into the mapping
        deathCertificates[_personAddress] = DeathCertificate({
            deathDate: _deathDate,
            deathPlace: _deathPlace,
            exist: true
        });

        return true;
   }

   /**
     * Get death certificate of specific person
     *
     * @param _personAddress    : Person address
     *
     * @return uint256, string
     */

   function getSpecificDeathCertificate(address _personAddress) public onlyAdmin view returns(uint256, string memory) {

       // Check if the person exist or the certificate exist
       require(persons[_personAddress].exist, "The person doesn't exist");
       require(deathCertificates[_personAddress].exist, "The certificate doesn't exist");

       return (deathCertificates[_personAddress].deathDate, deathCertificates[_personAddress].deathPlace);
   }

}
