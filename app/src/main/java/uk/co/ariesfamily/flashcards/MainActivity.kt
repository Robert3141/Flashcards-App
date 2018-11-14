package uk.co.ariesfamily.flashcards

import android.Manifest.permission.READ_EXTERNAL_STORAGE
import android.Manifest.permission.WRITE_EXTERNAL_STORAGE
import android.content.*
import android.content.pm.PackageManager
import android.support.v7.app.AppCompatActivity
import android.os.*;
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.widget.Toast
import kotlinx.android.synthetic.main.activity_main.*
import java.io.InputStream
import java.lang.reflect.Array
import java.util.concurrent.ThreadLocalRandom
import kotlin.random.Random

class MainActivity : AppCompatActivity() {
    //create public

    //create privates
    private val FILEREQUESTCODE = 50
    private var wordsNotDefinition = true
    private var cardSelected = 0
    private var wordsFileArrayCounter = 0
    private var textFileString = ""


    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.ActivityTheme_Primary_Base_Dark)
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        //theme switching


        //disable buttons
        flipFlashcard.isClickable = false
        newFlashcard.isClickable = false
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == FILEREQUESTCODE && resultCode == RESULT_OK) {
            val fileSelectedPath = data?.data
            if (fileSelectedPath != null) {
                val inputStream = contentResolver.openInputStream(fileSelectedPath)
                textFileString = inputStream.bufferedReader().use { it.readText() }

            } else {
                //output no file exists
                Toast.makeText(this,"No Data", Toast.LENGTH_LONG).show()
            }
        }
    }

    fun clickThemeChanger(view:android.view.View){

    }

    fun clickFlipFlashcard(view: android.view.View){
        //read words file
        var wordsFileArray = readWordsFile()

        if(flipFlashcard.isClickable) {
            if(wordsNotDefinition) {
                cardSelected++
                wordsNotDefinition = false
            } else {
                cardSelected--
                wordsNotDefinition = true
            }

            //display new flashcard
            textViewOutput.text = wordsFileArray[cardSelected]
        }
    }

    fun clickNewFlashcard(view: android.view.View){
        //create local variables


        //read file and put to array
        var wordsFileArray = readWordsFile()

        //randomly select number and set relevant variables
        if (wordsFileArrayCounter > 0) {
            cardSelected = 2 * randomNumberGenerator(0,(wordsFileArrayCounter - 1) / 2)
        } else {
            cardSelected = 0
        }
        wordsNotDefinition = true
        flipFlashcard.isClickable = true

        //set displays text
        textViewOutput.text = wordsFileArray[cardSelected]
    }

    fun clickSelectFile(view: android.view.View){
        //create locals
        val intent = Intent().setType("*/*").setAction(Intent.ACTION_GET_CONTENT)

        //enable button
        newFlashcard.isClickable = true

        //request file
        startActivityForResult(Intent.createChooser(intent, "Select a file"), FILEREQUESTCODE)
    }

    private fun readWordsFile(): kotlin.Array<String>{
        //create local variables
        val STRINGSPLIT = '&'

        var tempString = ""

        //reset variables
        wordsFileArrayCounter = 0

        //Temp stuff
        //textFileString = "Card1a&Card1b&Card2a&Card2b&Card3a&Card3b&Card4a&Card4b&Card5a&Card5b&"

        var wordsFileArray = Array(textFileString.length, {""})

        //string splitting
        for(i in textFileString.indices) {
            if(textFileString[i].equals(STRINGSPLIT)){

                wordsFileArray[wordsFileArrayCounter] = tempString
                wordsFileArrayCounter++
                tempString = ""
            } else {
                tempString += textFileString[i]
            }
        }
        wordsFileArray[wordsFileArrayCounter] = tempString
        wordsFileArrayCounter++

        return wordsFileArray
    }

    private fun randomNumberGenerator(min: Int,max: Int): Int{
        return (min..max).random()
    }

    private fun IntRange.random() =
            ThreadLocalRandom.current().nextInt((endInclusive + 1) - start) + start

}
