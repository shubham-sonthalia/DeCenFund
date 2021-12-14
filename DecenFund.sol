pragma solidity >=0.7.0 < 0.9.0;

import "./Project.sol";


/** @title contract to manage projects */
contract DecenFund{
    address public owner;
    uint public numOfProjects;
    // maintain array of beneficiary addresses
    address[] public listOfBeneficiaries;
    // mapping of project hash to project object
    mapping (bytes32 => Project) public projects;
    // maintain the collected amount so for a project
    mapping(address => uint) collectedAmount;

    event EventProjectCreated(uint id, string title, Project addr, address creator);
    event DonationSent(address projectAddress, address beneficiary, uint amount);

    event Error(string message);
    event ProjectDeleted(address projectAddress);
    modifier onlyOwner {
        require(msg.sender == owner, "You don't have the rights to perform this action.");
        _;
    }
    constructor() {
        owner = msg.sender;
        numOfProjects = 0;
    }
    
    /** @dev Create a new project for a beneficiary.
      * @param _name beneficiary name
      * @param _age beneficiary age
      * @param _emailID email address of beneficiary
      * @param _targetAmount target amount for project in wei's
      * @param _targetInDays deadline for project in days
      * @param _title Project Title
      * @return projectAddress The address of newly created project
      * @return _beneficiary The address of beneficiary
      */
    function createProject(string calldata _name, string calldata _age, string calldata _emailID, uint _targetAmount, uint _targetInDays, string calldata _title) external payable 
    returns (Project projectAddress, address _beneficiary) {
        
        address payable benAdd = payable(address(uint160(uint256(keccak256(abi.encodePacked(_name, _age, _emailID))))));
        listOfBeneficiaries.push(benAdd);
        if (_targetAmount <= 0) {
            emit Error("Project funding goal must be greater than 0");
            revert("Project funding goal must be greater than 0");
        }
        
        if (_targetInDays <= 0) {
            emit Error("Project deadline must be greater than the current block");
            revert("Project deadline must be greater than the current block");
        }
        
        bytes32 projectHash = keccak256(abi.encodePacked(_targetAmount, _targetInDays, _title, _emailID));
        Project p = new Project(_targetAmount, _targetInDays, _title, benAdd, _emailID);
        projects[projectHash] = p;
        emit EventProjectCreated(numOfProjects, _title, p, benAdd);
        numOfProjects++;
        return (p, benAdd);
    }
    
    /** @dev Donate to a project address
      * @param _projectAddress The address of an ongoing project
      * @return successful Indicates if the transfer was successful or not
      */
    function donate(address _projectAddress) external payable returns (bool successful) { 
        
        if(msg.value <= 0){
            emit Error("Donations must be greater than 0 wei");
            revert("Donations must be greater than 0 wei");
        }
        Project deployedProject = Project(_projectAddress);
        // Check that there is actually a Project contract at that address
        if (deployedProject.DF() == address(0)) {
            emit Error("Project contract not found at address");
            revert("Project contract not found at address");
        }

        // Check that fund call was successful
        if (deployedProject.fund(msg.sender, msg.value)) {
            emit DonationSent(_projectAddress, msg.sender, msg.value);
            return true;
        } else {
            emit Error("Contribution did not send successfully");
            return false;
        }
    }

    /** @dev Delete a project
      * @param _hash Hash of the project address
      */
    function deleteProject(bytes32 _hash) public {
        numOfProjects--;
        delete projects[_hash];
        emit ProjectDeleted(msg.sender);
    }

    /** @dev Get balance of the beneficiary
      * @param _beneficiaryAddress address of beneficiary
      * @return balance amount
      */
    function getCreatorBalance(address _beneficiaryAddress) external view returns (uint) {
        return collectedAmount[_beneficiaryAddress];
    }

    /** @dev Transfer funds to beneficiary
      * @param _beneficiary address of beneficiary
      * @param _payment amount to deposit
      */    
    function receivePayment(address _beneficiary, uint _payment) public payable {
        collectedAmount[_beneficiary] += _payment;
    }
    
    fallback() external{
        revert('Fallback error');
    }
    
}
