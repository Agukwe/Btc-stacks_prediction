# **Prediction Market and Oracle Contracts**

This project consists of two Clarity smart contracts designed to work together on the Stacks blockchain:

1. **`prediction-market.clar`**: A decentralized prediction market where users can create events, stake tokens on outcomes, and resolve events.
2. **`oracle-contract.clar`**: A contract that manages a list of trusted oracles, which can be used to resolve events in the prediction market.

---

## **Table of Contents**
1. [Overview](#overview)
2. [Features](#features)
3. [How to Use](#how-to-use)
   - [Deploying the Contracts](#deploying-the-contracts)
   - [Creating an Event](#creating-an-event)
   - [Staking Tokens](#staking-tokens)
   - [Resolving an Event](#resolving-an-event)
   - [Querying Data](#querying-data)
4. [Contract Details](#contract-details)
   - [Prediction Market Contract](#prediction-market-contract)
   - [Oracle Contract](#oracle-contract)
5. [Testing](#testing)
6. [License](#license)

---

## **Overview**

This project enables users to create and participate in prediction events on the Stacks blockchain. Events can be resolved by either the event creator or a trusted oracle, ensuring fairness and transparency. The `oracle-contract` manages a list of trusted oracles, while the `prediction-market` contract handles event creation, staking, and resolution.

---

## **Features**

### **Prediction Market Contract**
- Create prediction events with a title, description, and deadline.
- Stake STX tokens on event outcomes ("Yes" or "No").
- Resolve events and distribute winnings to participants.
- Track total stakes and calculate potential payouts.
- Charge a 5% fee on the losing pool.

### **Oracle Contract**
- Add and remove trusted oracles (only callable by the contract owner).
- Check if an address is a trusted oracle.
- Ensure only trusted oracles or event creators can resolve events.

---

## **How to Use**

### **Deploying the Contracts**
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/prediction-market.git
   cd prediction-market
   ```
2. Start the Clarinet console:
   ```bash
   clarinet console
   ```
3. Deploy the contracts:
   ```clarity
   ::deploy oracle-contract
   ::deploy prediction-market
   ```

---

### **Creating an Event**
Use the `create-event` function to create a new prediction event:
```clarity
(contract-call? .prediction-market create-event "Will BTC hit $100K?" "Predict BTC price." u100000)
```
- **Parameters**:
  - `title`: Event title (e.g., "Will BTC hit $100K?").
  - `description`: Event description (e.g., "Predict BTC price.").
  - `deadline`: Block height at which the event expires (e.g., `u100000`).

---

### **Staking Tokens**
Use the `stake` function to stake tokens on an event outcome:
```clarity
(contract-call? .prediction-market stake u1 "Yes" u1000)
```
- **Parameters**:
  - `event-id`: ID of the event (e.g., `u1`).
  - `outcome`: Outcome to stake on ("Yes" or "No").
  - `amount`: Amount of STX tokens to stake (in microSTX, e.g., `u1000`).

---

### **Resolving an Event**
Use the `resolve-event` function to resolve an event:
```clarity
(contract-call? .prediction-market resolve-event u1 "Yes")
```
- **Parameters**:
  - `event-id`: ID of the event (e.g., `u1`).
  - `outcome`: Correct outcome ("Yes" or "No").

Only the event creator or a trusted oracle can resolve an event.

---

### **Querying Data**
Use the following read-only functions to query data:

#### **Get Event Details**
```clarity
(contract-call? .prediction-market get-event u1)
```

#### **Get Total Stakes**
```clarity
(contract-call? .prediction-market get-total-stakes u1)
```

#### **Get Participant's Stake**
```clarity
(contract-call? .prediction-market get-participant-stake u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

#### **Check if an Address is a Trusted Oracle**
```clarity
(contract-call? .oracle-contract is-trusted-oracle 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

---

## **Contract Details**

### **Prediction Market Contract**
- **File**: `contracts/prediction-market.clar`
- **Key Functions**:
  - `create-event`: Create a new prediction event.
  - `stake`: Stake tokens on an event outcome.
  - `resolve-event`: Resolve an event and distribute winnings.
  - `get-event`, `get-total-stakes`, `get-participant-stake`: Query event data.

### **Oracle Contract**
- **File**: `contracts/oracle-contract.clar`
- **Key Functions**:
  - `add-trusted-oracle`: Add a trusted oracle.
  - `remove-trusted-oracle`: Remove a trusted oracle.
  - `is-trusted-oracle`: Check if an address is a trusted oracle.

---

## **Testing**

1. Run unit tests using Clarinet:
   ```bash
   clarinet test
   ```
2. Test the contracts interactively in the Clarinet console:
   ```bash
   clarinet console
   ```

---

## **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---



For more information, refer to the [Clarity documentation](https://docs.stacks.co/docs/write-smart-contracts/). Let me know if you need further assistance!