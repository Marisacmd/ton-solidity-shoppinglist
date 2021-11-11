pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "../Debot.sol";
import "../Terminal.sol";
import "../Menu.sol";
import "../AddressInput.sol";
import "../ConfirmInput.sol";
import "../Upgradable.sol";
import "../Sdk.sol";
import "ITransactable.sol";
import "HasConstructorWithPubKey.sol";

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

interface IPurchase {
    function createPurchase(string name, uint amount) external;
    function updatePurchase(uint32 id, bool done, uint price) external;
    function deletePurchase(uint32 id) external;
    function getPurchases() external returns(Purchase[] purchases);
    function getStat() external returns(Stat);
}

contract ShoppingListDebot is Debot, Upgradable {
    bytes m_icon;

    TvmCell m_purchaseCode;
    TvmCell public m_purchaseData;
    TvmCell public m_purchaseStateInit;
    address m_address;
    Stat m_stat;
    uint32 m_purchaseId;
    uint256 m_masterPubKey;
    address m_msigAddress;

    uint32 INITIAL_BALANCE = 200000000;


    function setPurchaseCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_purchaseCode = code;
        m_purchaseData = data;
        m_purchaseStateInit = tvm.buildStateInit(m_purchaseCode, m_purchaseData);
    }


    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    function onSuccess() public view {
        _getStat(tvm.functionId(setStat));
    }

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey), "Please enter your public key", false);
    }

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shopping List DeBot";
        version = "0.1.0";
        publisher = "Marisacmd";
        key = "Shopping (purchases) list manager";
        author = "Marisacmd";
        hello = "Hi, i'm a Shopping List DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns(uint256[] interfaces) {
        return [Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID];
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x" + value);
        if (status) {
            m_masterPubKey = res;

            Terminal.print(0, "Checking if you already have a Shopping list ...");
            TvmCell deployState = tvm.insertPubkey(m_purchaseStateInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format("Info: your Shopping list contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkAccountStatus), m_address);

        } else {
            Terminal.input(tvm.functionId(savePublicKey), "Wrong public key. Try again!\nPlease enter your public key", false);
        }
    }


    function checkAccountStatus(int8 acc_type) public {
        if (acc_type == 1) {
            _getStat(tvm.functionId(setStat));

        } else if (acc_type == -1) {
            Terminal.print(0, "You don't have a Shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount), "Select a wallet for payment. We will ask you to sign two transactions");

        } else if (acc_type == 0) {
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your Shopping list contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }


    function creditAccount(address value) public {
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        ITransactable(m_msigAddress).sendTransaction {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        sdkError;
        exitCode;
        creditAccount(m_msigAddress);
    }

    function waitBeforeDeploy() public {
        Sdk.getAccountType(tvm.functionId(checkIfAccountExists), m_address);
    }

    function checkIfAccountExists(int8 acc_type) public {
        if (acc_type == 0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }


    function deploy() private view {
        TvmCell image = tvm.insertPubkey(m_purchaseStateInit, m_masterPubKey);
        optional(uint256) none;
        TvmCell deployMsg = tvm.buildExtMsg({
            abiVer: 2,
            dest: m_address,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onErrorRepeatDeploy),
            time: 0,
            expire: 0,
            sign: true,
            pubkey: none,
            stateInit: image,
            call: {
                HasConstructorWithPubKey,
                m_masterPubKey
            }
        });
        tvm.sendrawmsg(deployMsg, 1);
    }


    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        sdkError;
        exitCode;
        deploy();
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function setStat(Stat stat) public {
        m_stat = stat;
        _menu();
    }

    function _getStat(uint32 answerId) private view {
        optional(uint256) none;
        IPurchase(m_address).getStat {
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }


    function _menu() internal virtual {}

}
