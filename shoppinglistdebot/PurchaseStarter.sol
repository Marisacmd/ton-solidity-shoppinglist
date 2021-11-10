pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "ShoppingListDebot.sol";
import "commons_functions.sol";

contract PurchaseStarter is ShoppingListDebot, commons {

    string name;
    uint amount;

    function _menu() internal override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (todo/done/total) purchases",
                m_stat.incompleteCount,
                m_stat.completeCount,
                m_stat.completeCount + m_stat.incompleteCount
            ),
            sep,
            [
                MenuItem("Start new purchase", "", tvm.functionId(createPurchase)),
                MenuItem("Show purchases list", "", tvm.functionId(showPurchases)),
                MenuItem("Delete purchase", "", tvm.functionId(deletePurchase))
            ]
        );
    }

    function createPurchase(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(createPurchase_), "Please enter purchase name", false);
    }

    function createPurchase_(string value) public {
        uint32 index;
        index = index;
        name = value;
        Terminal.input(tvm.functionId(createPurchase__), "Please enter amount of items in purchase", false);
    }

    function createPurchase__(string value) public {
        (uint256 num, ) = stoi(value);
        amount = uint(num);
        optional(uint256) pubkey = 0;
        IPurchase(m_address).createPurchase {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        }(name, amount);
    }

    function showPurchases(uint32 index) public {
        showPurchases_(m_address);
    }

    function deletePurchase(uint32 index) public {
        deletePurchase_(m_address, index);
    }

}
