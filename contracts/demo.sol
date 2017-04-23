pragma solidity ^0.4.0;
contract ContractBase
{
    string internal _name;
    address public _owner;
    function ContractBase() internal
    {
        _owner = msg.sender;
    }
    modifier _OnlyOwner()
    {
        if (msg.sender != _owner) throw;
        _;
    }
    function hash(string str) internal returns (bytes32 ret)
    {
        return keccak256(str);
    }
    function Name() constant returns (string)
    {
        return _name;
    }
}

contract AuthorityBase is ContractBase
{
    function AuthorityBase() internal
    {}

    mapping (address => bool) authenticated_entities;
    function ApproveEntity(address entity) _OnlyOwner
    {
        authenticated_entities[entity] = true;
    }
    function DisapproveEntity(address entity) _OnlyOwner
    {
        authenticated_entities[entity] = false;
    }
    function IsEntityAuthenticated(address entity) returns (bool)
    {
        return authenticated_entities[entity];
    }

    address private _supervising_authority;
    function SupervisingAuthority() returns (address)
    {
        return _supervising_authority;
    }
    function UpdateSupervisingAuthority(address addr) internal
    {
        _supervising_authority = addr;
    }
}

contract Authority_AU is AuthorityBase
{
    function Authority_AU()
    {
        _name = "Government of Australia";
    }
}

contract Authority_AUQLD is AuthorityBase
{
    function Authority_AUQLD(address AuthAU)
    {
        UpdateSupervisingAuthority(AuthAU);
        _name = "Government of Queensland";
    }
}

contract Authority_CA is AuthorityBase
{
    function Authority_CA()
    {
        _name = "Government of Canada";
    }
}

contract Authority_CAON is AuthorityBase
{
    function Authority_CAON(address AuthCA)
    {
        UpdateSupervisingAuthority(AuthCA);
        _name = "Government of Ontario";
    }
}

contract Authority_US is AuthorityBase
{
    function Authority_US()
    {
        _name = "Government of U.S.A.";
    }
}

contract Authority_USFL is AuthorityBase
{
    function Authority_USFL(address AuthUS)
    {
        UpdateSupervisingAuthority(AuthUS);
        _name = "Government of Florida";
    }
}

contract DMVBase is AuthorityBase
{
    struct plate_t
    {
        bool valid;
        string number;
        string vin;
        int256 sticker_expiry_date;
        address insurer;
        int256 insurance_expiry_date;
    }

    // Plate information
    mapping(bytes32 => plate_t) plates;
    mapping(bytes32 => bytes32) vin_to_key;
    function DMVBase() internal
    {
    }
    modifier _OnlyApprovedInsurer()
    {
        if (!IsApprovedInsurer(msg.sender)) throw;
        _;
    }
    modifier _OwnerOrApprovedInsurer()
    {
        if (msg.sender != _owner && !IsApprovedInsurer(msg.sender)) throw;
        _;
    }

    function query(bytes32 key) private _OwnerOrApprovedInsurer returns (string o_number, string o_vin, int256 o_sticker_expiry_date, address o_insurer, int256 o_insurance_expiry_date)
    {
        plate_t plate = plates[key];
        if (plate.valid)
        {
            o_number = plate.number;
            o_vin = plate.vin;
            o_sticker_expiry_date = plate.sticker_expiry_date;
            o_insurer = plate.insurer;
            o_insurance_expiry_date = plate.insurance_expiry_date;
        }
        else
        {
            throw;
        }
    }

    function CreatePlate(string number, string vin, int256 sticker_expiry_date, address insurer, int256 insurance_expiry_date) _OnlyOwner
    {
        bytes32 key =  hash(number);
        if (!plates[key].valid)
        {
            plates[key].valid = true;
            plates[key].number = number;
            plates[key].vin = vin;
            plates[key].sticker_expiry_date = sticker_expiry_date;
            plates[key].insurer = insurer;
            plates[key].insurance_expiry_date = insurance_expiry_date;
            vin_to_key[hash(vin)] = key;
        }
        else
        {
            throw;
        }
    }
    function RevokePlate(string number) _OnlyOwner
    {
        bytes32 key =  hash(number);
        if (plates[key].valid)
        {
            plates[key].valid = false;
        }
        else
        {
            throw;
        }
    }
    function UpdateStickerExpiryDate(string plate, int256 sticker_expiry_date) _OnlyOwner
    {
        bytes32 key =  hash(plate);
        if (plates[key].valid)
        {
            plates[key].sticker_expiry_date = sticker_expiry_date;
        }
        else
        {
            throw;
        }
    }
    function UpdateInsuranceExpireDate(string plate, int256 insurance_expiry_date) _OnlyApprovedInsurer
    {
        bytes32 key =  hash(plate);
        if (plates[key].valid)
        {
            plates[key].insurer = msg.sender;
            plates[key].insurance_expiry_date = insurance_expiry_date;
            return;
        }
    }
    function QueryNumber(string number) returns (string o_number, string o_vin, int256 o_sticker_expiry_date, address o_insurer, int256 o_insurance_expiry_date)
    {
        return query(hash(number));
    }
    function QueryVIN(string vin) returns (string o_number, string o_vin, int256 o_sticker_expiry_date, address o_insurer, int256 o_insurance_expiry_date)
    {
        return query(vin_to_key[hash(vin)]);
    }
    function ValidatePlateNumber(string number) returns (bool)
    {
        bytes32 key =  hash(number);
        return plates[key].valid;
    }

    // Insurance information
    mapping (address => bool) insurers;
    function ApproveInsurer(address insurer) _OnlyOwner
    {
        insurers[insurer] = true;
    }
    function DisapproveInsurer(address insurer) _OnlyOwner
    {
        insurers[insurer] = false;
    }
    function IsApprovedInsurer(address insurer) returns (bool)
    {
        return insurers[insurer];
    }
}

contract QueenslandDepartmentOfTransportAndMainRoads is DMVBase
{
    function QueenslandDepartmentOfTransportAndMainRoads(address AuthQUQLD)
    {
        UpdateSupervisingAuthority(AuthQUQLD);
        _name = "Queensland Department of Transport and Main Roads";
    }
}

contract OntarioMinistryOfTransportation is DMVBase
{
    function OntarioMinistryOfTransportation(address AuthCAON)
    {
        UpdateSupervisingAuthority(AuthCAON);
        _name = "Ontario Ministry of Transportation";
    }
}

contract FloridaDepartmentOfMotorVehicles is DMVBase
{
    function FloridaDepartmentOfMotorVehicles(address AuthUSFL)
    {
        UpdateSupervisingAuthority(AuthUSFL);
        _name = "Florida Department of Motor Vehicles";
    }
}
