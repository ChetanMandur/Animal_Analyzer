// ANIMAL ANALYSER 1.0
// Coded by: Jiwon Suh, Chetan Mandur, Nicolas Natter

// Importing the GUI
import g4p_controls.*;

//Initializing variables and arrays
PFont Font;

boolean answer;
boolean[][] answers;

String[] Questions;
String[] Animals;
String[] animalNames;

int[] possibleAnimals;
int[] nextPossibleAnimals;
int[] possibleQuestions;
int[] nextPossibleQuestions;

boolean changeQ = true;
boolean newQ = true;
IntList questionsAsked;
int CurrentQ;

boolean questionBack = true;
String answerGiven = "none";

IntList animalsExcluded;
boolean gameStart = false;

// Initialize screen, animal data
void setup() {
  // Create the interface screen
  size(800, 600);
  background(255);
  
  // Initialize variables
  questionsAsked = new IntList();
  animalsExcluded = new IntList();
  Font = createFont ("Arial",27);
  
  // Loading the animal data and questions from data files
  Animals = loadStrings("Animals.txt");
  Questions = loadStrings("Questions.txt");
  
  // Creating arrays for the program to interact with
  answers = new boolean [Animals.length][Questions.length+1];
  animalNames = new String [Animals.length];
  
  // Transforms the raw strings into a more suitable form
  for (int i = 0; i < Animals.length; i++) { //This is the line of code that is used to build the 2d array based on the text file
    String nextAnimal = Animals[i]; //Grabs the current line of text in the animal text file
    String[] thisRowAnimals = nextAnimal.split(","); //Splits the line from the comma
    String animalName = thisRowAnimals[0]; //The name of the animal is the first value of the array

    for (int j=1; j<= Questions.length;j++){ //Starting from the second column (since first are animal names), check each question
      if ( int(thisRowAnimals[j]) ==  0){ //If the row+column has the value '1', the answer is false
        answer = false;
      }
      else if (int(thisRowAnimals[j]) ==  1){ //If the row+column has the value '0', the answer is true
        answer = true;
      }
      //After each column is checked the main array is updated
      answers[i][j-1] = answer;
      animalNames[i]=animalName;
    }
  }
  
  // Preparing the data sets for analysis
  possibleAnimals = new int[animalNames.length];
  for(int i=0; i < animalNames.length; i++){
    possibleAnimals[i] = i;
  }
  
  // Preparing the data sets for analysis
  possibleQuestions = new int[Questions.length];
  for(int i=0; i < Questions.length; i++){
    possibleQuestions[i] = i;
  }

  // Create the GUI objects
  createGUI();
}

// Return string containing 1/3 of the animal names
String getAnimalNames(){
  String names = "";
  String separator = "";
  for (int i=0; i<animalNames.length; i++){
    names += separator + animalNames[i];
    separator = "\n";
  }
  return names;
}

void draw(){
  // Sets the font
  textFont(Font);
  fill(0);
  
  // When the game is started, the start button is hidden
  if (gameStart == true){
    startButton.setVisible(false);

    // When one animal remains, the answer is provided and the yes and no buttons are hidden
    if (possibleAnimals.length == 1) {
      yesButton.setVisible(false);
      noButton.setVisible(false);
      background(255);
      
      // The name of the final animal is chosen and printed to the screen
      String finalAnimalName = animalNames[possibleAnimals[0]];
      textAlign(CENTER, CENTER);
      text("Your animal is: " + finalAnimalName, 400, 275);
    }

    // If more than one animal remains continue to ask more questions
    if (changeQ == true){
      yesButton.setVisible(true);
      noButton.setVisible(true);
      resetButton.setVisible(true);
      
      // If an answer has been given:
      if (answerGiven != "none"){
        // Set the current answer to false
        boolean CurrentA = false;
        // If the answer given by the user was "yes":
        if (answerGiven == "yes"){
          // Change the current answer to true
          CurrentA = true;
        }
        
        // Remove the non-matching animals from possibleAnimals
        nextPossibleAnimals = new int[0];
        for(int i=0; i < possibleAnimals.length; i++){
          int animalIdx = possibleAnimals[i];
          if(answers[animalIdx][CurrentQ] == CurrentA){                                   //If the answer for the animal is the same as the current answer,
            nextPossibleAnimals = append(nextPossibleAnimals, possibleAnimals[i]);
          }
        }
        // Set the possible animals for the next question that is asked
        possibleAnimals = nextPossibleAnimals;
      }
      // Ask another question
      if (newQ == true){
        try{
          CurrentQ = bestQ();
        }
        catch(Exception e){
        }
        // Removes the old question
        background(255);
        // Displays the new question
        textAlign(CENTER, CENTER);
        text(Questions[CurrentQ],400,275);
        newQ = false;
      }
      changeQ = false;
    }
  }
  else {
    // Hide the buttons
    yesButton.setVisible(false);
    noButton.setVisible(false);
    resetButton.setVisible(false);
  }
}

// Function to determine the best question to ask
int bestQ(){
  // Initializing variables and arrays
  int bestQuestion = -1;
  int nextQuestionIdx = -1;
  float bestPercentage = 0.0;
  int totalAnimals = possibleAnimals.length;
  int[] numberOfTrues = new int[possibleQuestions.length];
  nextPossibleQuestions = new int[0];
  
  // For each question that hasn't been removed:
  for(int i=0; i < possibleQuestions.length; i++){
    int questionIdx = possibleQuestions[i];
    numberOfTrues[i] = 0;
    float currPercentage = 0.0;
    // For each animal that hasn't been removed:
    for(int j=0; j < possibleAnimals.length; j++){
      int animalIdx = possibleAnimals[j];
      // For each answer that is true, add one to the amount of trues
      if(answers[animalIdx][questionIdx] == true){
        numberOfTrues[i] += 1;
      }
    }
    
    // Remove questions where all animals have the same answer (all animals have true, or all animals have false
    if(numberOfTrues[i] > 0 && numberOfTrues[i] < totalAnimals){
      nextPossibleQuestions = append(nextPossibleQuestions, possibleQuestions[i]);
      nextQuestionIdx += 1;
      currPercentage = float(numberOfTrues[i])/float(totalAnimals);
      // If the percentage for this question is greater than 50%:
      if(currPercentage > 0.5){
        // Set the percentage to 100% - 50%
        currPercentage = 1 - currPercentage;
      }
      // If the percentage for this question is better than the current best:
      if(currPercentage > bestPercentage){
        // Set this question as the best question
        bestPercentage = currPercentage;
        bestQuestion = nextQuestionIdx;
      }
    }
  }
  
  // Appending the possible questions with all the good questions except the question asked
  possibleQuestions = new int[0];
  for(int i=0; i < nextPossibleQuestions.length; i++){
    // If the question is not the best question:
    if(i != bestQuestion){
      // Add it to the questions that can be asked next time
      possibleQuestions = append(possibleQuestions, nextPossibleQuestions[i]);
    }
  }
  // Return the value for the best question to ask
  return nextPossibleQuestions[bestQuestion];
}
