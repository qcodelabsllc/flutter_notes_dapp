// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract NotesContract {
    uint256 public notes_count = 0;

    struct Note {
        uint256 id;
        string title;
        string description;
    }

    mapping(uint256 => Note) public notes;

    event CreateNote(uint256 id, string title, string description);
    event DeleteNote(uint256 id);

    function createNote(string memory _title, string memory _description) public {
        notes[notes_count] = Note(notes_count, _title, _description);
        emit CreateNote(notes_count, _title, _description);
        notes_count++;
    }

    function deleteNote(uint256 _id) public {
        delete notes[_id];
        emit DeleteNote(_id);
        notes_count--;
    }

}
