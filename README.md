# Telam

Simple Alamofire networking wrapper utilizing Combine and Codable/Decodable for parameter encoding and decoding

## Usage

### Configuration

```swift
let networkClient = Telam.configure(with: "https://example-base-url.com")
```
### Creating request and response models

Telam uses the Encodable protocol under the hood to encode request parameters and the Decodable protocol to decode the response objects. You can use Encodable and Decodable or semantic typealiases of them which Telam provides.

```swift
public typealias QueryRequestable = Encodable
public typealias BodyRequestable = Encodable
public typealias Respondable = Decodable
```

```swift
struct RegisterUserBodyRequest: BodyRequestable {
    let name: String
    let email: String
    let password: String
    let address: String
}

struct SearchUsersQueryRequest: QueryRequestable {
    let searchTerm: String
}

struct UsersResponse: Respondable {
    let count: Int
    let users: [User]
}
```

Nested objects are also supported, they just need to conform to Encodable/Decodable protocols.

### Structuring
In order to create a request using the Telam instance a type conforming to APIConfigurable needs to be created. Usually a repository class is created which will conform to a Repositable protocol containing all methods which the repository will provide. Inside the repository an enum is created which will conform to the APIConfigurable protocol and will contain the parameters for each request.

```swift
protocol Repositable {
    func getUsers() -> AnyPublisher<UsersResponse, Error>
}

class Repository: Repositable {
    let networkClient: Telam
    
    init(with networkClient: Telam) {
        self.networkClient = networkClient
    }
    
    func getUsers() -> AnyPublisher<UsersResponse, Error> {
        return networkClient.request(for: Endpoint.getUsers)
    }
}

extension Repository {
    enum Endpoint {
        case getUsers
    }
}

extension Repository.Endpoint: APIConfigurable {
    var path: String {
        switch self {
        case .getUsers: return "/users"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUsers: return .get
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getUsers: return nil
        }
    }
    
    var queryRequestable: QueryRequestable? {
        switch self {
        case .getUsers: return nil
        }
    }
    
    var bodyRequestable: BodyRequestable? {
        switch self {
        case .getUsers: return nil
        }
    }
}
```

### Full example

```swift
protocol Repositable {
    func registerUser(with bodyRequest: BodyRequestable) -> AnyPublisher<Discardable, Error>
    func searchUsers(with queryRequest: QueryRequestable) -> AnyPublisher<UsersResponse, Error>
    func getUsers() -> AnyPublisher<UsersResponse, Error>
}

class Repository: Repositable {
    let networkClient: Telam
    
    init(with networkClient: Telam) {
        self.networkClient = networkClient
    }
    
    func getUsers() -> AnyPublisher<UsersResponse, Error> {
        return networkClient.request(for: Endpoint.getUsers)
    }
    
    func registerUser(with bodyRequest: BodyRequestable) -> AnyPublisher<Discardable, Error> {
        return networkClient.request(for: Endpoint.registerUser(bodyRequest))
    }
    
    func searchUsers(with queryRequest: QueryRequestable) -> AnyPublisher<UsersResponse, Error> {
        return networkClient.request(for: Endpoint.searchUsers(queryRequest))
    }
}

extension Repository {
    enum Endpoint {
        case registerUser(BodyRequestable)
        case searchUsers(QueryRequestable)
        case getUsers
    }
}

extension Repository.Endpoint: APIConfigurable {
    var path: String {
        switch self {
        case .getUsers, .searchUsers: return "/users"
        case .registerUser: return "/register"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUsers: return .get
        case .registerUser: return .post
        case .searchUsers: return .get
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getUsers: return nil
        case .registerUser: return ["Content-Type": "application/json"]
        case .searchUsers: return nil
        }
    }
    
    var queryRequestable: QueryRequestable? {
        switch self {
        case .getUsers: return nil
        case .registerUser: return nil
        case .searchUsers(let queryRequest): return queryRequest
        }
    }
    
    var bodyRequestable: BodyRequestable? {
        switch self {
        case .getUsers: return nil
        case .registerUser(let bodyRequest): return bodyRequest
        case .searchUsers: return nil
        }
    }
}
```

If we do not need a response of a request we can use Discardable for the return type
