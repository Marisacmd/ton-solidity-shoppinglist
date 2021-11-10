pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

contract commons_variables {

    struct Purchase {
        uint32 id;
        string name;
        uint amount;
        uint price;
        uint64 createdAt;
        bool isDone;
    }

struct Stat {
    uint32 completeCount;
    uint32 incompleteCount;
}
}