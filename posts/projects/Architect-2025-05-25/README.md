# Investigating Different Architectures for our TaskManager App

Before we get too deep into the visual design, we're going to look at MVVM, VIPER, and TCA as different ways of organizing your iOS SwiftUI app.

Unlike our previous sample code sections, this one will have individual directory structures for each of the individual architectures.

In each case, we'll set up our basic app with the same standard behavior:

* Three tabs:
  * List View
    * Collapsible list of projects
    * Collapsible list of the tasks or notes within each project
    * Collapsible list of notes within each task
    * Clicking on a task should bring up a detail view where the TaskManager task/note children are converted to a reminder/calendar event that can be exported to Apple Reminders/Calendar.
        
    Each item can be rearranged up and down the hierarchy to attach them to a new owner. If they were collapsed, all of their children come along with them.
  * Text View
  
    This is a textual version of the whole Task Manager list. Editing this will enable changes to the List View and vice versa.

  * Settings View
  
    This is a list of the various setting options each setting option have various UI elements: sliders, toggles, text fields and each should persist the data, as well as affecting the state of the app.

## MVVM

[Sample Code](./MVVM/TaskManager/)

### Model - View - View Model 

`View` ↔️ `View Model` ↔️ `Model`

#### Model

As we've talked through multiple blog posts so far, we have a lot of models that make up the various elements of the Task Manager data.

#### View

These will be our UI/UX layer, as described above. It won't communicate directly with the model. Each view will have the appropriate *View Model*.

#### View Model

Each view model handles both the data segregation so that each *View* only sees the data that they're supposed to as well as the business logic to ensure that the *Model* can be updated.

## VIPER

[Sample Code](./VIPER/TaskManager/)

### View - Presenter (Router) - Interactor - Entity

`View` ↔️ `Presenter` ↔️ `Interactor` ↔️ `Entity`

As well as this:

`Presenter` ↔️ `Router`

#### View

This is our UI/UX layer, as described above. It communicates through the *Presenter*. This ensures that the view only has the data it needs and the only only interactions are the ones available.

#### Interactor

This layer handles the changes to the *Entity* (known as the model layer in other architectures). Business logic usually goes here.

#### Presenter

This layer handles preparing the data from the *Entity* for the *View* and handles the user interactions that would need to update the entities.

#### Entity

This layer is our data models. And sometimes the service lay to retrieve/update from the end points.

#### Router

This layer handles the the navigation and routing between views.

## TCA

[Sample Code](./TCA/TaskManager/)

**T**he **C**omposable **A**rchitecture is a Swift adaption of the Redux framework. It follows a *Unidirectional Data Flow* model to ensure state management and a single source of truth.

The three components flow from one to another in a single direction:

### State - View - Action

`State` ➡️ `View` ➡️ `Action` ↩️

Each flows from one to the other in a single direction: `State` to `View` to `Action` and back to `State`.

#### State

The state of your app. This can contain the data/model to ensure that the state is contained. As state can also refer to a specific view, it could also refer to the state of the view itself.

#### Action

All possible supported actions that the app can perform. As action can also refer to a specific view, it could also refer to all of the available actions that the view can perform.

#### Reducer

Encapsulates the business logic, taking an *Action* and returns an *Effect*.

#### Effect

An effect is a wrapper around any piece of work or a task such a network call or an asynchronous task. This could result in a new *Action* that can be fed back into the *Reducer*.

#### Environment

This layer is where network, persistant storage, OS service functionality goes.

#### Store

This wraps everything together, including the initial state and the reducer, as well as the initializer.