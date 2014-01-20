//
//  ToDoViewController.m
//  todo
//
//  Created by Thanawat Kaewka on 1/18/14.
//  Copyright (c) 2014 thanawat. All rights reserved.
//

#import "ToDoViewController.h"
#import "ToDoCell.h"
#import <objc/runtime.h>

static char indexPathKey;

@interface ToDoViewController ()

@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSString *filePath;

@property (strong, nonatomic) UIBarButtonItem *addBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *doneBarButtonItem;


- (void) onDoneButton;
- (void) onAddButton;
- (void) saveToFile:(UITextField *)textField;

@end

@implementation ToDoViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSArray *filepaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [filepaths objectAtIndex:0];
        self.filePath = [documentsDirectory stringByAppendingPathComponent:@"todos.txt"];
        self.items  = [[NSMutableArray alloc] initWithContentsOfFile:self.filePath];
        if(self.items == nil){
            self.items = [[NSMutableArray alloc]init];
        }
        //Initialize all button properties
        self.addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target: self action: @selector(onAddButton)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Nav bar
    self.navigationItem.title = @"To Do List";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = self.addBarButtonItem;
    self.doneBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(onDoneButton)];
    
    // Custom todo nib.
    UINib *toDoNib = [UINib nibWithNibName:@"ToDoCell" bundle:nil];
    [self.tableView registerNib:toDoNib forCellReuseIdentifier:@"ToDoCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing  animated:animated] ;
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ToDoCell";
    ToDoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.toDoTextField.delegate = self;
    objc_setAssociatedObject(cell.toDoTextField, &indexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *celltext = [self.items objectAtIndex:indexPath.row];
    cell.toDoTextField.text = celltext;
    [self.items writeToFile:self.filePath atomically:YES];
    return cell;
}

- (void) onAddButton{
    self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
    [self.items insertObject:@"" atIndex:0];
    
    [self.tableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *tablecell =  [self.tableView cellForRowAtIndexPath:indexPath];
    ToDoCell *cell = (ToDoCell *)tablecell;
    [cell.toDoTextField becomeFirstResponder];
}

- (void) onDoneButton {
    [self.view endEditing:YES];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
    return YES;
}


- (void) saveToFile:(UITextField *)textField {
    NSIndexPath *indexPath = objc_getAssociatedObject(textField, &indexPathKey);
    [self.items replaceObjectAtIndex:indexPath.row withObject:textField.text] ;
    [self.items writeToFile:self.filePath atomically:YES];
    [self.tableView reloadData];
    [textField resignFirstResponder];
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField{
    [self saveToFile:textField];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self saveToFile:textField];
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    self.navigationItem.rightBarButtonItem = self.addBarButtonItem;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.items writeToFile:self.filePath atomically:YES];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if(self.tableView.editing){
        UITableViewCell *fromtablecell =  [self.tableView cellForRowAtIndexPath:fromIndexPath];
        ToDoCell *fromcell = (ToDoCell *)fromtablecell;
        NSString* temp = fromcell.toDoTextField.text;
        
        UITableViewCell *totablecell =  [self.tableView cellForRowAtIndexPath:toIndexPath];
        ToDoCell *tocell = (ToDoCell *)totablecell;
        NSString* totext = tocell.toDoTextField.text;
        
        [self.items replaceObjectAtIndex:fromIndexPath.row withObject:totext];
        [self.tableView reloadData];
        [self.items replaceObjectAtIndex:toIndexPath.row withObject:temp];
        [self.tableView reloadData];
        [self.items writeToFile:self.filePath atomically:YES];
        
    }
}

@end
