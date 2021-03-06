pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "ShoppingListDebot.sol";

contract commons is ShoppingListDebot {

    function showPurchases_(address ListAddress) public view {
        optional(uint256) none;
        IPurchase(m_address).getPurchases {
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showPurchases__),
            onErrorId: 0
        }();
    }

    function showPurchases__(Purchase[] purchases) public {
        uint32 i;
        if (purchases.length > 0) {
            Terminal.print(0, "Your shopping list:");
            for (i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string completed;
                if (purchase.isDone) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\"  amount {} at {} price {}", purchase.id, completed, purchase.name, purchase.amount, purchase.createdAt, purchase.price));
            }
        } else {
            Terminal.print(0, "Your purchases list is empty");
        }
        _menu();
    }

   address l_address;

        function deletePurchase_(address addr, uint32 index) public {
        l_address = addr;
        deletePurchase__(index);
    }


    function deletePurchase__(uint32 index) public {

        index = index;
        if (m_stat.completeCount + m_stat.incompleteCount > 0) {
            Terminal.input(tvm.functionId(deletePurchase___), "Enter purchase index:", false);
        } else {
            Terminal.print(0, "Sorry, you have no items to delete");
            _menu();
        }
    }

    function deletePurchase___(string value) public view {
        (uint256 num, ) = stoi(value);
        IPurchase(l_address).deletePurchase {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: m_masterPubKey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        }(uint32(num));
    }


}
