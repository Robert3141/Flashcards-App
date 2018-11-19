package uk.co.ariesfamily.flashcards

import android.Manifest.permission.READ_EXTERNAL_STORAGE
import android.Manifest.permission.WRITE_EXTERNAL_STORAGE
import android.content.*
import android.content.pm.PackageManager
import android.support.v7.app.AppCompatActivity
import android.os.*;
import android.preference.PreferenceManager
import android.provider.Settings
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.view.View
import android.widget.Toast
import kotlinx.android.synthetic.main.activity_main.*
import java.io.InputStream
import java.lang.reflect.Array
import java.util.concurrent.ThreadLocalRandom
import kotlin.random.Random

class MainActivity : AppCompatActivity() {
    //create public

    //create privates
    private val wordsFileRequestCode = 50
    private val savedTheme1 = "Theme1"
    private val savedWordsFile = "wordsFile"
    private var wordsNotDefinition = true
    private var cardSelected = 0
    private var wordsFileArrayCounter = 0
    private var textFileString = ""


    override fun onCreate(savedInstanceState: Bundle?) {
        //create locals
        val pref = PreferenceManager.getDefaultSharedPreferences(this)
        val themeName = pref.getString(savedTheme1,"Default")
        val textFileStringSaved = pref.getString(savedWordsFile,"")
        val editor = pref.edit()

        //get saved theme
        if (themeName == "Dark"){
            setTheme(R.style.ActivityTheme_Primary_Base_Dark)
        } else {
            setTheme(R.style.AppTheme)
        }

        //create interface
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        //disable buttons
        flipFlashcard.isClickable = false
        newFlashcard.isClickable = false

        //set text file
        if (textFileStringSaved != ""){
            //set file
            textFileString = textFileStringSaved

            //enable button
            newFlashcard.isClickable = true

            //new flashcard
            clickNewFlashcard(flipFlashcard)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        //word file found
        if (requestCode == wordsFileRequestCode && resultCode == RESULT_OK) {
            val fileSelectedPath = data?.data
            if (fileSelectedPath != null) {
                //locals
                val inputStream = contentResolver.openInputStream(fileSelectedPath)
                val pref = PreferenceManager.getDefaultSharedPreferences(this)
                var editor = pref.edit()

                //set file
                textFileString = inputStream.bufferedReader().use { it.readText() }

                //enable button
                newFlashcard.isClickable = true

                //save text file
                editor.putString(savedWordsFile,textFileString)
                editor.commit()
            } else {
                //output no file exists
                Toast.makeText(this,"No Data", Toast.LENGTH_LONG).show()
            }
        }
    }

    fun clickThemeChanger(view:android.view.View){
        //check theme
        var pref = PreferenceManager.getDefaultSharedPreferences(this)
        var themeName = pref.getString(savedTheme1,"Default")
        var editor = pref.edit()

        if(themeName == "Dark") {
            editor.putString(savedTheme1,"Default")
        } else {
            editor.putString(savedTheme1,"Dark")
        }
        //push theme
        editor.commit()

        //reload activity
        recreate()
    }

    fun clickFlipFlashcard(view: android.view.View){
        //read words file
        val wordsFileArray = readWordsFile()

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
        val wordsFileArray = readWordsFile()

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

        //request file
        startActivityForResult(Intent.createChooser(intent, "Select a file"), wordsFileRequestCode)
    }

    private fun readWordsFile(): kotlin.Array<String>{
        //create local variables
        val stringSplit = '&'
        val wordsFileArray = Array(textFileString.length, {""})
        var tempString = ""

        //reset variables
        wordsFileArrayCounter = 0



        //string splitting
        for(i in textFileString.indices) {
            if(textFileString[i] == stringSplit){

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

    private fun IntRange.random() = ThreadLocalRandom.current().nextInt((endInclusive + 1) - start) + start

    /*private fun getSettings(): kotlin.Array<String>{
        return
    }*/
}
