pragma solidity ^0.4.0;
contract ContractBase
{
    address public _owner;
    function ContractBase()
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
}

contract Insurer is ContractBase
{
    struct policy_t
    {
        bool valid;
        address jurisdiction;
        string vin;
        int256 expires;
    }
    string public _name;
    mapping(bytes32 => policy_t) policies;
    function Insurer(string name)
    {
        _name = name;
    }

    function CreatePolicy(address jurisdiction, string vin) _OnlyOwner
    {
        bytes32 key = hash(vin);
        if (!policies[key].valid)
        {
            // TODO check if jurisdiction is valid
            policies[key].valid = true;
            policies[key].jurisdiction = jurisdiction;
            policies[key].vin = vin;
        }
        else
        {
            throw;
        }
    }
    function RevokePolicy(string vin) _OnlyOwner
    {
        bytes32 key = hash(vin);
        if (policies[key].valid)
        {
            policies[key].valid = false;
        }
        else
        {
            throw;
        }
    }
    function UpdatePolicy(string vin, int256 expires) _OnlyOwner
    {
        bytes32 key = hash(vin);
        if (policies[key].valid)
        {
            policies[key].expires = expires;
        }
        else
        {
            throw;
        }
    }
    function QueryPolicy(string vin) returns (address o_jurisdiction, int256 o_expires)
    {
        bytes32 key = hash(vin);
        if (policies[key].valid)
        {
            o_jurisdiction = policies[key].jurisdiction;
            o_expires = policies[key].expires;
        }
        else
        {
            throw;
        }
    }
}

contract DMV is ContractBase
{
    struct plate_t
    {
        bool valid;
        string number;
        string vin;
        int256 expires;
        address insurer;
    }

    // Plate information
    mapping(bytes32 => plate_t) plates;
    mapping(bytes32 => bytes32) vin_to_key;
    string public _jurisdiction;
    function DMV(string jurisdiction)
    {
        _jurisdiction = jurisdiction;
    }
    function query(bytes32 key) private returns (string o_number, string o_vin, int256 o_expires, address o_insurer)
    {
        plate_t plate = plates[key];
        if (plate.valid)
        {
            o_number = plate.number;
            o_vin = plate.vin;
            o_expires = plate.expires;
            o_insurer = plate.insurer;
        }
        else
        {
            throw;
        }
    }

    function CreatePlate(string number, string vin) _OnlyOwner
    {
        bytes32 key =  hash(number);
        if (!plates[key].valid)
        {
            plates[key].valid = true;
            plates[key].number = number;
            plates[key].vin = vin;
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
    function UpdateValidity(string plate, int256 expires) _OnlyOwner
    {
        bytes32 key =  hash(plate);
        if (plates[key].valid)
        {
            plates[key].expires = expires;
        }
        else
        {
            throw;
        }
    }
    function UpdateInsurer(string plate, address insurer) _OnlyOwner
    {
        if (IsApprovedInsurer(insurer))
        {
            bytes32 key =  hash(plate);
            if (plates[key].valid)
            {
                plates[key].insurer = insurer;
                return;
            }
        }
        throw;
    }
    function QueryNumber(string number) returns (string o_number, string o_vin, int256 o_expires, address o_insurer)
    {
        return query(hash(number));
    }
    function QueryVIN(string vin) returns (string o_number, string o_vin, int256 o_expires, address o_insurer)
    {
        return query(vin_to_key[hash(vin)]);
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
    function IsApprovedInsurer(address insurer) returns (bool ret)
    {
        return insurers[insurer];
    }
}
