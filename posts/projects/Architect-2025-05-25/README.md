# Investigating Different Architectures for our TaskManager App

Before we get too deep into the visual design, we're going to look at MVVM and TCA as different ways of organizing your iOS SwiftUI app.

Unlike our previous sample code sections, this one will have individual directory structures for each of the individual architectures.

In each case, we'll set up our basic app with the same standard behavior:

* Three tabs:
  * List View
    * Add/Edit/Remove items into the projects/tasks/text list.
    * List of projects/tasks/text
    * Clicking on a task should bring up a detail view where the TaskManager task.
        
  * Text View
  
    This is a textual version of the whole Task Manager list. Editing this will convert to our appropriate task types. (For the moment, the list view and the text view are separate and editing one does not affect the other.)

  * Settings View
  
    For the moment, this is a placeholder view. In the future this will be a list of the various setting options, which each setting option having the appropriate UI element for that: sliders for numeric range values, toggles for boolean values, text fields for data entry, and each should persist the data that will affect the state of the app.

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

##### Two flavors

I have both MVVM and MVVM with combine for the MVVM functionality.

[With Combine Sample Code](./MVVM-Combine/TaskManager/)

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