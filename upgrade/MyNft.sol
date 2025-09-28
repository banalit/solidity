// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
/**
作业2：在测试网上发行一个图文并茂的 NFT
任务目标 
1.使用 Solidity 编写一个符合 ERC721 标准的 NFT 合约。
2.将图文数据上传到 IPFS，生成元数据链接。
3.将合约部署到以太坊测试网（如 Goerli 或 Sepolia）。
4.铸造 NFT 并在测试网环境中查看。
任务步骤 
4.1编写 NFT 合约
使用 OpenZeppelin 的 ERC721 库编写一个 NFT 合约。
合约应包含以下功能：
构造函数：设置 NFT 的名称和符号。
mintNFT 函数：允许用户铸造 NFT，并关联元数据链接（tokenURI）。
在 Remix IDE 中编译合约。
4.2准备图文数据
准备一张图片，并将其上传到 IPFS（可以使用 Pinata 或其他工具）。
创建一个 JSON 文件，描述 NFT 的属性（如名称、描述、图片链接等）。
将 JSON 文件上传到 IPFS，获取元数据链接。
JSON文件参考 https://docs.opensea.io/docs/metadata-standards
4.3部署合约到测试网
在 Remix IDE 中连接 MetaMask，并确保 MetaMask 连接到 Goerli 或 Sepolia 测试网。
部署 NFT 合约到测试网，并记录合约地址。
4.4铸造 NFT
使用 mintNFT 函数铸造 NFT：
在 recipient 字段中输入你的钱包地址。
在 tokenURI 字段中输入元数据的 IPFS 链接。
在 MetaMask 中确认交易。
4.5查看 NFT
打开 OpenSea 测试网 或 Etherscan 测试网。
连接你的钱包，查看你铸造的 NFT
*/

contract MyNFT is IERC721, Ownable {
    using Address for address;
    using Strings for uint256;

    // 接口ID定义（ERC165规定的标准接口ID）
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd; // IERC721的接口ID
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7; // IERC165自身的接口ID

    // NFT名称和符号
    string private _name;
    string private _symbol;
    
    // 记录每个tokenId的所有者
    mapping(uint256 tokenId => address owner) private _owners;
    
    // 记录每个地址拥有的token数量
    mapping(address owner=> uint256 tokenIdCount) private _balances;
    
    // 记录授权地址
    mapping(uint256 tokenId=> address approved) private _tokenApprovals;
    
    // 记录批量授权
    mapping(address operator=> mapping(address spender=> bool approved)) private _operatorApprovals;
    
    // 下一个要铸造的token ID
    uint256 private _nextTokenId;
    
    // 存储token的元数据URI
    mapping(uint256 tokenId=> string metaDataUrl) private _tokenURIs;

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId, uint256 timestamp);
    event Transfer(address from, address indexed recipient, uint256 tokenId, uint256 indexed timestamp);

    constructor(
        string memory name_,
        string memory symbol_
    ) Ownable(msg.sender) {
        _name = name_;
        _symbol = symbol_;
        _nextTokenId = 1;
    }

    /**
     * @dev 实现ERC165接口，用于检查合约是否支持特定的接口
     * @param interfaceId 要检查的接口ID
     * @return bool 是否支持该接口
     */
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        // 支持IERC165自身、IERC721接口
        return 
            interfaceId == _INTERFACE_ID_ERC165 || 
            interfaceId == _INTERFACE_ID_ERC721;
    }

    /**
     * @dev 返回NFT名称
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev 返回NFT符号
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the metadata URI for a given token ID.
    */
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        require(_exists(_tokenId), "Token does not exist");
        return _tokenURIs[_tokenId];
    }

    /**
     * @dev 查看tokenId的所有者
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "Token does not exist");
        address owner = _owners[tokenId];
        return owner;
    }

    /**
     * @dev 查看地址拥有的token数量
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Owner is zero address");
        return _balances[owner];
    }

    /**
     * @dev 转移NFT
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not eligible");
        require(ownerOf(tokenId) == from, "From is not owner");
        require(to != address(0), "To is zero address");
        _transfer(from, to, tokenId);
    }

    /**
     * @dev 批准地址使用NFT
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(owner!=address(0), "Token not exist");
        require(to != owner, "Cannot approve to owner heself");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not owner or approved");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId, block.timestamp);

    }

    /**
     * @dev 查看token的授权账户地址
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "Token does not exist");
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev 批量授权
     */
    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Cannot approve self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev 查看是否批量授权
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev 安全转移NFT
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev 带数据的安全转移NFT
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved or owner");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev 铸造NFT
     */
    function mintNFT(address recipient, string memory iTokenURI) public onlyOwner returns (uint256) {
        require(recipient != address(0), "Recipient is zero address");
        
        uint256 tokenId = _nextTokenId++;
        
        _balances[recipient]++;
        _owners[tokenId] = recipient;
        _tokenURIs[tokenId] = iTokenURI;
        
        emit Transfer(address(0), recipient, tokenId, block.timestamp);
        
        return tokenId;
    }

    /**
     * @dev 检查token是否存在
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev 检查是否有权限操作token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev 执行转移操作
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;
        delete _tokenApprovals[tokenId];
        emit Transfer(from, to, tokenId, block.timestamp);
    }

    /**
     * @dev 安全转移，检查接收者是否能接收NFT
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "Transfer to non-receiving contract");
    }

    /**
     * @dev 检查接收合约是否实现了接收函数
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("Transfer to non-receiving contract");
                } else {
                    assembly {
                        //revert(错误信息的内存起始地址, 错误信息的长度)
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}

// 导入ERC721接收接口
// interface IERC721Receiver {
//     function onERC721Received(
//         address operator,
//         address from,
//         uint256 tokenId,
//         bytes calldata data
//     ) external returns (bytes4);
// }
    