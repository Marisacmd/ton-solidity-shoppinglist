pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "ShoppingListDebot.sol";
import "commons_functions.sol";

contract PurchaseFinisher is ShoppingListDebot, commons {

    uint price;
    bool updatePurchase__ConfirmInputValue;
    address p_address;

    constructor(address PurchasesListAddress) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        p_address = PurchasesListAddress;
    }

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
                MenuItem("Finish purchase", "", tvm.functionId(updatePurchase)),
                MenuItem("Show purchases list", "", tvm.functionId(showPurchases)),
                MenuItem("Delete purchase", "", tvm.functionId(deletePurchase))
            ]
        );
    }

    function updatePurchase(uint32 index) public {
        index = index;
        if (m_stat.completeCount + m_stat.incompleteCount > 0) {
            Terminal.input(tvm.functionId(updatePurchase_), "Enter purchase index:", false);
        } else {
            Terminal.print(0, "Sorry, you have no items to update");
            _menu();
        }
    }

    function updatePurchase_(string value) public {
        (uint256 num, ) = stoi(value);
        uint32 purchaseId;
        m_purchaseId = uint32(num);
        ConfirmInput.get(tvm.functionId(updatePurchase__), "Is this purchase finished?");
    }


    function updatePurchase__(bool value) public {
        updatePurchase__ConfirmInputValue = value;
        Terminal.input(tvm.functionId(updatePurchase___), "Please enter price per item:", false);
    }


    function updatePurchase___(string value) public {
        (uint256 num, ) = stoi(value);
        price = uint(num);
        optional(uint256) pubkey = 0;
        IPurchase(p_address).updatePurchase {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        }(m_purchaseId, updatePurchase__ConfirmInputValue, price);
    }

    function showPurchases(uint32 index) public {
        showPurchases_(p_address);
    }

    function deletePurchase(uint32 index) public {

        index = index;
        if (m_stat.completeCount + m_stat.incompleteCount > 0) {
            Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no items to delete");
            _menu();
        }
    }

    function deletePurchase_(string value) public view {
        (uint256 num, ) = stoi(value);
        optional(uint256) pubkey = 0;
        IPurchase(p_address).deletePurchase {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        }(uint32(num));
    }
}