//
//  TableViewController.swift
//  DashMe
//
//  Created by leanne on 3/3/16.
//  Copyright © 2016 Jai Rai. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
	
	// MARK: - Properties
	
	let tableCellReuseIdentifier = "reusableTableCell"
	
	// indicates whether this controller initiated a segue
	//  used to determine whether this controller can respond to an unwind request
	var startedEditorSegue = false
	var startedDetailSegue = false
	
	
	// MARK: - Table View Controller Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.leftBarButtonItem = editButtonItem
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let numDashs = DashData.allDashs.count
		let isEmpty = (numDashs == 0)
		
		navigationItem.leftBarButtonItem?.isEnabled = !isEmpty
		
		setUpTableViewBackground(isEmpty)

		// reload table to ensure all Dashs are displayed
		tableView.reloadData()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		guard let segueId = segue.identifier else {
			return
		}
		
		switch segueId {
			
		case "tableViewSegueToDetail":
			let sendingCell = sender as! UITableViewCell
			let sendingCellIndexPath = tableView.indexPath(for: sendingCell)!
			let selectedDash = sendingCellIndexPath.row
			
			let controller = segue.destination as! DetailViewController
			controller.selectedDash = DashData.allDashs[selectedDash]
			
			startedDetailSegue = true
			
		case "tableViewSegueToEditor":
			startedEditorSegue = true
		
		default:
			print("unknown segue: \(segueId)")
		}
	}
	
	override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
		
		// if we started the segue, then we can handle it; otherwise, pass
		switch action {
			
		case #selector(TableViewController.unwindFromEditor(_:)):
			let isUnwindResponder = startedDetailSegue || startedEditorSegue
			
			return isUnwindResponder
			
		default:
			return false
		}
	}
	
	
	// MARK: - Actions
	
	@IBAction func unwindFromEditor(_ segue: UIStoryboardSegue) {
		
		// the editor's unwind came here; all we need do is revert the indicator
		//	to false, so it's valid for the next unwind action
		startedEditorSegue = false
		startedDetailSegue = false
	}
	
	
	// MARK: - Table View Data Source

	// using default number of sections (1), so no override for numberOfSections

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		let numRows = DashData.allDashs.count
		
		return numRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellReuseIdentifier, for: indexPath)
		
		let currentDash = DashData.allDashs[indexPath.row]
		
		let cellImageView = cell.viewWithTag(1) as! UIImageView
		cellImageView.image = currentDash.DashdImage
		
		let topText = currentDash.topDashText
		let bottomText = currentDash.bottomDashText
		let labelText: String = generateLabelText(topText!, bottomText: bottomText!)
		
		let cellLabel = cell.viewWithTag(2) as! UILabel
		cellLabel.text = labelText

        return cell
    }
	
	
	// MARK: - Table View Delegate
	
	// required to allow row deletion
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		
		return true
	}
	
	// do the deletion
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			DashData.allDashs.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .automatic)
			
			// Done button doesn't change back automatically (as of Xcode 7, iOS 9),
			//	so let's save the user some effort and change it back for them
			if DashData.allDashs.count == 0 {
				let editButton = navigationItem.leftBarButtonItem!
				editButton.title = "Edit"
				editButton.isEnabled = false
				
				let isEmpty = true
				setUpTableViewBackground(isEmpty)
			}
		}
	}
	
	
	// MARK: - Utility Functions
	
	func setUpTableViewBackground(_ isEmpty: Bool) {
		
		// code modified from:
		// iOS Programming 101: Implementing Pull-to-Refresh and Handling Empty Table
		//	Simon Ng, 11 July 2014
		//	http://www.appcoda.com/pull-to-refresh-uitableview-empty/
		
		let emptyMessageText = "No board created yet!\nPress + to create a new board"
		let fontName = "Palatino-Italic"
		let fontSize: CGFloat = 20.0
		
		if !isEmpty {
			if tableView.backgroundView != nil {
				tableView.backgroundView = nil
				tableView.separatorStyle = .singleLine
			}
		}
		else {
			if tableView.backgroundView == nil {
				let emptyMessageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
				emptyMessageLabel.text = emptyMessageText
				emptyMessageLabel.numberOfLines = 0
				emptyMessageLabel.font = UIFont(name: fontName, size: fontSize)
				emptyMessageLabel.textAlignment = .center
				emptyMessageLabel.sizeToFit()
				
				tableView.backgroundView = emptyMessageLabel
				tableView.separatorStyle = .none
			}
		}
	}
	
	func generateLabelText(_ topText: String, bottomText: String) -> String {
		
		let ellipsis = "..."
		
		let maxNumCharsAvail = 22
		let halfNumCharsAvail = maxNumCharsAvail / 2
		
		let topTextLen = topText.count
		let bottomTextLen = bottomText.count
		
		var remainingCharsAvail = maxNumCharsAvail
		var labelText = ""
		
		// set up first half label...
		if topTextLen <= halfNumCharsAvail {
			labelText += topText
		}
		else {
			// truncate top text to halfway point
			let index = topText.index(topText.startIndex, offsetBy: halfNumCharsAvail)
			labelText += String(topText[..<index])
		}
		
		remainingCharsAvail -= labelText.count
		
		labelText += ellipsis
		
		// set up second half label
		if bottomTextLen <= remainingCharsAvail {
			labelText += bottomText
		}
		else {
			// truncate bottom text to fit
			if remainingCharsAvail <= halfNumCharsAvail {
				// no room left over from the front, so simply truncate
				let index = bottomText.index(bottomText.endIndex, offsetBy: -(remainingCharsAvail))
				labelText += String(bottomText[index...])
			}
			else {
				// room was left at the front, so split the truncation between front and back
				// get remainder at front; fill it with beginning of bottom text
				let numCharsLeftAtFront = remainingCharsAvail - halfNumCharsAvail
				let frontIndex = bottomText.index(bottomText.startIndex, offsetBy: numCharsLeftAtFront)
				labelText += String(bottomText[..<frontIndex])
				
				// add ellipsis
				labelText += ellipsis
				remainingCharsAvail = halfNumCharsAvail - ellipsis.count
				
				// get remainder at end; fill with ending of bottom text
				let backIndex = bottomText.index(bottomText.endIndex, offsetBy: -(remainingCharsAvail))
				labelText += bottomText[backIndex...]
			}
		}
		
		return labelText
	}
}
