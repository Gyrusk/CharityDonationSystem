// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharityPlatform {
    struct CharityEvent {
        string name;
        string description;
        address payable organizer;
        uint goalAmount;
        uint raisedAmount;
        bool isCompleted;
    }

    CharityEvent[] public charityEvents;

    event CharityEventCreated(uint eventId, string name, uint goalAmount, address organizer);
    event DonationMade(uint eventId, uint amount, address donor);

    function createCharityEvent(string memory _name, string memory _description, uint _goalAmount) public {
        CharityEvent memory newEvent = CharityEvent({
            name: _name,
            description: _description,
            organizer: payable(msg.sender),
            goalAmount: _goalAmount,
            raisedAmount: 0,
            isCompleted: false
        });

        charityEvents.push(newEvent);
        emit CharityEventCreated(charityEvents.length - 1, _name, _goalAmount, msg.sender);
    }

    function donateToCharity(uint _eventId) public payable {
        require(_eventId < charityEvents.length, "Charity event does not exist.");
        CharityEvent storage charityEvent = charityEvents[_eventId];
        require(!charityEvent.isCompleted, "This event is already completed.");

        charityEvent.raisedAmount += msg.value;

        if (charityEvent.raisedAmount >= charityEvent.goalAmount) {
            charityEvent.isCompleted = true;
        }

        emit DonationMade(_eventId, msg.value, msg.sender);
    }

    function getCharityEvents() public view returns (CharityEvent[] memory) {
        return charityEvents;
    }

    function withdrawFunds(uint _eventId) public {
        require(_eventId < charityEvents.length, "Charity event does not exist.");
        CharityEvent storage charityEvent = charityEvents[_eventId];
        require(msg.sender == charityEvent.organizer, "Only the organizer can withdraw funds.");
        require(charityEvent.isCompleted, "The event is not yet completed.");

        charityEvent.organizer.transfer(charityEvent.raisedAmount);
    }
}
