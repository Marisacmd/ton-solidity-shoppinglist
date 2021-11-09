pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import "commons_variables.sol";

contract ShoppingList is commons_variables {

    uint32 m_count;
    uint256 m_ownerPubkey;

    mapping(uint32 => Purchase) m_purchases;

    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }


    constructor(uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function createPurchase(string name, uint amount) public onlyOwner {
        tvm.accept();
        m_count++;
        m_purchases[m_count] = Purchase(m_count, name, amount, 0, now, false);
    }

    function updatePurchase(uint32 id, bool done, uint price) public onlyOwner {
        require(m_purchases.exists(id), 102);
        tvm.accept();
        Purchase purchase = m_purchases[id];
        purchase.isDone = done;
        purchase.price = price;
        m_purchases[id] = purchase;
    }

    function deletePurchase(uint32 id) public onlyOwner {
        require(m_purchases.exists(id), 102);
        tvm.accept();
        delete m_purchases[id];
    }

    function getPurchases() public view returns(Purchase[] purchases) {
        string name;
        uint amount;
        uint64 createdAt;
        bool isDone;
        uint price;

        for ((uint32 id, Purchase purchase): m_purchases) {
            name = purchase.name;
            isDone = purchase.isDone;
            createdAt = purchase.createdAt;
            amount = purchase.amount;
            price = purchase.price;
            purchases.push(Purchase(id, name, amount, price, createdAt, isDone));
        }
    }

    function getStat() public view returns(Stat stat) {
        uint32 completeCount;
        uint32 incompleteCount;

        for ((, Purchase purchase): m_purchases) {
            if (purchase.isDone) {
                completeCount++;
            } else {
                incompleteCount++;
            }
        }
        stat = Stat(completeCount, incompleteCount);
    }
}