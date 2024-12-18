// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DaoControl is ERC20 {

    address public owner; // Owner of the contract
    

    enum Role {None, Member, Admin}
    mapping(address => Role) public roles;
    mapping(address => bool) public isAnAdmin;

    address[] public memberList;
    address[] public adminList;
    address[] public userList;

    event RoleUpdated(address indexed account, Role role);
    event UserCountUpdated(uint256 userCount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyAdmin(address addy) {
        require(roles[addy] == Role.Admin, "Not an admin, you have be an admin to access function" );
        _;
    }
    
    modifier onlyMembers(address addy) {
        require(roles[addy] == Role.Member, "You have to be a member to access this function" );
        _;
    }

    constructor() ERC20("DaoToken", "DKT") {
        owner = msg.sender; // Set the contract deployer as the owner
        _mint(msg.sender, 10000); // Initial minting to the owner
        _mint(address(this), 277524000); // Mint total supply to the contract itself

        roles[msg.sender] = Role.Admin;
        adminList.push(msg.sender);
    }

    function ownerMint(address to, uint256 amount) internal onlyOwner {
        _mint(to, amount);
    }


     function createUser(address account) public onlyOwner {
        require(account != address(0), "Invalid address"); 
        require(account != msg.sender, "The owner can't be a user");
        userList.push(account); 
    }

     function addAdmin(address newAdmin) public {
        require(roles[newAdmin] != Role.Admin, "Address is already an admin");
        roles[newAdmin] = Role.Admin;
        adminList.push(newAdmin);
    }


    // Function to assign roles
        function addRole(address adminAddress, address account, Role role) internal onlyAdmin(adminAddress) {
            require(account != msg.sender, "Owner cannot be assigned a role.");
            require(roles[account] != role, "Account already has this role.");

            roles[account] = role;

            if (role == Role.Admin) {
                adminList.push(account);
                emit RoleUpdated(account, Role.Admin);
            } else if (role == Role.Member) {
                memberList.push(account);
                emit RoleUpdated(account, Role.Member);
            }
        }

    function findIndexAdmin(address account) internal view returns (uint) {
        for (uint i = 0; i < adminList.length; i++) {
            if (adminList[i] == account) {
                return i;
            }
        }
        return adminList.length; // Return an invalid index if the account is not found
    }

    function removeAdmin(address account) internal  onlyOwner() {
        require(roles[account] == Role.Admin, "Not an Admin, role can't be changed");
        require(account != msg.sender, "Owner can only be an Admin" );
        roles[account] = Role.None;

        uint indexToRemove = findIndexAdmin(account);
        require(indexToRemove < memberList.length, "Address not found in member list");

        // Shift elements to fill the removed element's spot
        for (uint i = indexToRemove; i < memberList.length - 1; i++) {
            memberList[i] = memberList[i + 1];
        }

        // Pop the last element (now duplicate after shifting)
        memberList.pop();

        emit RoleUpdated(account, Role.None);


        
    }

    function findIndex(address account) internal view returns (uint) {
        for (uint i = 0; i < memberList.length; i++) {
            if (memberList[i] == account) {
                return i;
            }
        }
        return memberList.length; // Return an invalid index if the account is not found
    }


    function removeMember(address adminAddress, address account ) internal  onlyAdmin(adminAddress) {
        require(roles[account] == Role.Member, "Not an Member, role can't be changed");
        require(account != msg.sender, "Owner can only be an Admin" );
        roles[account] = Role.None;
        
        uint indexToRemove = findIndex(account);
        require(indexToRemove < memberList.length, "Address not found in member list");

        // Shift elements to fill the removed element's spot
        for (uint i = indexToRemove; i < memberList.length - 1; i++) {
            memberList[i] = memberList[i + 1];
        }

        // Pop the last element (now duplicate after shifting)
        memberList.pop();

        emit RoleUpdated(account, Role.None);

    }

    function viewRole(address account) public view returns(Role) {
        return roles[account];
    }

    function numberUsers() public view returns(uint256) {
        uint nUsers;
        nUsers = userList.length;
        return nUsers;
    } 

    function getUsers() public view returns (address[] memory) {
        return userList;
    }




}

