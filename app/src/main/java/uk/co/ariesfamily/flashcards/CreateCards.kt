package uk.co.ariesfamily.flashcards


import android.content.Context
import android.content.Intent
import android.net.Uri
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.preference.PreferenceManager
import android.support.v4.graphics.PathUtils
import android.view.MenuItem
import android.view.View
import android.widget.Toast
import kotlinx.android.synthetic.main.activity_create_cards.*
import kotlinx.android.synthetic.main.activity_main.*
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream
import java.io.OutputStreamWriter
import java.net.URI


class CreateCards : AppCompatActivity() {

    private val savedTheme1 = "Theme1"
    private val savedWordsFile = "wordsFile"
    private val savedPageNumber = "pageNumber"
    private val savedFilePath = "filepath"
    private val newwordsFileRequestCode = 100

    private var textFileString = ""
    private var wordsFileArrayCounter = 0
    private var fileSelectedPath = Uri.EMPTY




    override fun onCreate(savedInstanceState: Bundle?) {
        //create locals
        val pref = PreferenceManager.getDefaultSharedPreferences(this)
        val themeName = pref.getInt(savedTheme1,0)
        val textFileStringSaved = pref.getString(savedWordsFile,"")
        val pageNumberSaved = pref.getInt(savedPageNumber,0)
        val path = pref.getString(savedFilePath,"")

        //get saved setup
        when (themeName){
            1 -> setTheme(R.style.ActivityTheme_Primary_Base_Dark)
            2 -> setTheme(R.style.nightTheme)
            3 -> setTheme(R.style.whitTheme)
            else -> setTheme(R.style.AppTheme)
        }

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_create_cards)

        //disable buttons
        buttonNext.isClickable = false
        buttonPrevious.isClickable = false

        //set text file
        if (textFileStringSaved != ""){
            //set file
            textFileString = textFileStringSaved
            fileSelectedPath = Uri.parse(path)

            //new flashcard
            choosePage(pageNumberSaved)
        } else {

        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        //word file found
        if (requestCode == newwordsFileRequestCode && resultCode == RESULT_OK) {
            fileSelectedPath = data?.data
            if (fileSelectedPath != null) {
                //locals
                val inputStream = contentResolver.openInputStream(fileSelectedPath)
                val pref = PreferenceManager.getDefaultSharedPreferences(this)
                var editor = pref.edit()
                editor.putString(savedFilePath,fileSelectedPath.toString())

                //set file
                textFileString = inputStream.bufferedReader().use { it.readText() }.toString()

                //enable button
                buttonNext.isClickable = true

                //save text file
                editor.putString(savedWordsFile,textFileString)
                editor.commit()

                //run choose page
                choosePage(1)

            } else {
                //output no file exists
                Toast.makeText(this,"No Data", Toast.LENGTH_LONG).show()
            }
        }
    }

    //onclick events for launching activities
    fun startMain(item: MenuItem) {
        val intent = Intent(this, MainActivity::class.java).apply {}
        startActivity(intent)
    }
    fun startNewCards(item: MenuItem) {
        val intent = Intent(this, CreateCards::class.java).apply {  }
        startActivity(intent)
    }
    fun startSettings(item: MenuItem) {
        val intent = Intent(this, Settings::class.java).apply {  }
        startActivity(intent)
    }
    fun startHelp(item: MenuItem) {
        val intent = Intent(this, Help::class.java).apply {  }
        startActivity(intent)
    }
    //back button
    fun backButtonPress(view: android.view.View){
        val intent = Intent(this, MainActivity::class.java).apply {}
        startActivity(intent)
    }


    fun clickSelectFileButton(view: android.view.View){
        //create locals
        val intent = Intent().setType("*/*").setAction(Intent.ACTION_GET_CONTENT)

        //request file
        startActivityForResult(Intent.createChooser(intent, "Select a file"), newwordsFileRequestCode)
    }

    fun clickPrevious(view: android.view.View){
        var pref = PreferenceManager.getDefaultSharedPreferences(this)
        var pageNo = pref.getInt(savedPageNumber,2)
        choosePage(pageNo-1)
    }

    fun clickNext(view: android.view.View){
        var pref = PreferenceManager.getDefaultSharedPreferences(this)
        var pageNo = pref.getInt(savedPageNumber,1)
        choosePage(pageNo+1)
    }

    fun choosePage(pageNo: Int){
        //do check first
        if (pageNo > 0){

            //create local variables
            var pref = PreferenceManager.getDefaultSharedPreferences(this)
            var editor = pref.edit()

            //read file and put to array
            val wordsFileArray = saveFile()

            //display flashcards
            if(wordsFileArrayCounter >= pageNo * 2) {
                editTextTerm.setText(wordsFileArray[((pageNo+1)*2-1)])
                editTextDef.setText(wordsFileArray[((pageNo+1)*2)])
            } else {
                textFileString += "&&"
                readWordsFile()
                editTextTerm.setText(wordsFileArray[((pageNo+1)*2-1)])
                editTextDef.setText(wordsFileArray[((pageNo+1)*2)])
            }

            //button click ability
            buttonNext.isClickable = true
            buttonPrevious.isClickable = pageNo > 1

            //display other outputs
            textViewNumber.text = pageNo.toString()
            textViewFileData.text = textFileString
            textViewFileURL.text = fileSelectedPath.toString()

            //save page number
            editor.putInt(savedPageNumber,pageNo)
            editor.commit()
        }
    }

    private fun readWordsFile(): kotlin.Array<String>{
        //create local variables
        val stringSplit = '&'
        var tempString = ""
        var wordsFileArray = Array(textFileString.length/2, {""})

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

    fun saveFile(): kotlin.Array<String>{
        //create local variables
        val file = File(FileUtils.getPath(this, fileSelectedPath))
        var pref = PreferenceManager.getDefaultSharedPreferences(this)
        var editor = pref.edit()
        var pageNo = pref.getInt(savedPageNumber,1)
        var wordsFileArray = readWordsFile()


        //save updates to array
        wordsFileArray[((pageNo+1)*2-1)] = editTextTerm.text.toString()
        wordsFileArray[((pageNo+1)*2)] = editTextTerm.text.toString()

        //convert to string
        textFileString = ""
        for (i in wordsFileArray.indices){
            textFileString += wordsFileArray[i] + "&"
        }

        //write to file
        file.printWriter().use { out ->
            out.println(textFileString)
        }

        return wordsFileArray
    }

}
