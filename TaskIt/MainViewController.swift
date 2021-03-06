//
//  MainViewController.swift
//  TaskIt
//
//  Created by Keenan Jaenicke on 1/11/15.
//  Copyright (c) 2015 Keenan Jaenicke. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    
    var fetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib (nibName: "TestTaskCellTableViewCell", bundle: nil), forCellReuseIdentifier: "testId")
        
        fetchedResultsController = getFetchResultsController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTaskDetail" {
            let detailVC:TaskDetailViewController = segue.destinationViewController as TaskDetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            let thisTask = fetchedResultsController.objectAtIndexPath(indexPath!) as TaskModel
            detailVC.detailTaskModel = thisTask
        }
        else if segue.identifier == "showTaskAdd" {
            let addTaskVC:AddTaskViewController = segue.destinationViewController as AddTaskViewController
        }
    }
    
    @IBAction func addButtonTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("showTaskAdd", sender: self)
    }
    
    
    
    //UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thisTask = fetchedResultsController.objectAtIndexPath(indexPath) as TaskModel
        var cell: TestTaskCellTableViewCell = tableView.dequeueReusableCellWithIdentifier("testId") as TestTaskCellTableViewCell
        cell.taskLabel.text = thisTask.task
        cell.subtaskLabel.text = thisTask.subtask
        cell.dateLabel.text = Date.toString(date:thisTask.date)
        return cell
    }
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        performSegueWithIdentifier("showTaskDetail", sender: self)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 25
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (fetchedResultsController.sections?.count == 1){
            let fetchedObjects = fetchedResultsController.fetchedObjects!
            let testTask:TaskModel = fetchedObjects[0] as TaskModel
            
            if(testTask.completed == true){
                return "Completed"
            }
            else {
                return "To Do"
            }
        }
        else {
            if section == 0 {
                return "To Do"
            }
            else {
                return "Completed"
            }
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let thisTask = fetchedResultsController.objectAtIndexPath(indexPath) as TaskModel
        
        thisTask.completed = !(thisTask.completed as Bool)
        
        //save whatever changes we make to our entity
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
    }
    
    //NSFetchedResultsControllerDelegate
    
    //if we have changes to our entities - reload the tableview
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
    
    //helpers
    
    func taskFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "TaskModel")
        let sortDescription = NSSortDescriptor(key: "date", ascending: true)
        let completedDescriptor = NSSortDescriptor(key: "completed", ascending: true)
        fetchRequest.sortDescriptors = [completedDescriptor, sortDescription]
        
        return fetchRequest
    }
    
    func getFetchResultsController() -> NSFetchedResultsController {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: taskFetchRequest(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: "completed", cacheName: nil)
        
        return fetchedResultsController
    }
    
    
    
}
