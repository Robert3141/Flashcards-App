package uk.co.ariesfamily.flashcards
import android.animation.Animator
import android.animation.AnimatorInflater
import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.content.*
import android.support.v7.app.AppCompatActivity
import android.os.*
import android.preference.PreferenceManager
import android.support.v4.view.GestureDetectorCompat
import android.util.Log
import android.view.GestureDetector
import android.view.MenuItem
import android.view.MotionEvent
import android.view.View
import android.widget.PopupMenu
import android.widget.Toast
import kotlinx.android.synthetic.main.activity_main.*
import kotlinx.android.synthetic.main.card_back.*
import kotlinx.android.synthetic.main.card_front.*
import java.lang.Exception
import java.util.concurrent.ThreadLocalRandom




class MainActivity : AppCompatActivity() {
    //create public

    //create privates
    private val wordsFileRequestCode = 50
    private val savedTheme1 = "Theme1"
    private val savedWordsFile = "wordsFile"
    private val savedFlashcardFlipper = "flashcardFlipper"
    private val savedFlashcardNumber = "flashcardNumber"
    private val savedFilePath = "filepath"
    private val savedFlashcardOrder = "flashcardOrder"
    private var wordsNotDefinition = true
    private var cardSelected = 0
    private var wordsFileArrayCounter = 0
    private var textFileString = ""
    private var justRecreated = false
    private var backOfCardVisible = false

    override fun onCreate(savedInstanceState: Bundle?) {
        //create locals
        val pref = PreferenceManager.getDefaultSharedPreferences(this)
        //val editor = pref.edit()
        //editor.clear()
        //editor.commit()
        val themeName = pref.getInt(savedTheme1,0)
        val textFileStringSaved = pref.getString(savedWordsFile,"")

        //get saved theme
        when (themeName){
            1 -> setTheme(R.style.ActivityTheme_Primary_Base_Dark)
            2 -> setTheme(R.style.nightTheme)
            3 -> setTheme(R.style.whitTheme)
            else -> setTheme(R.style.AppTheme)
        }

        //create interface
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        backOfCardVisible = true
        flipAnimation()


        //disable buttons
        chevron_left.isClickable = false
        chevron_right.isClickable = false

        //create menu
        menu_launch.setOnClickListener{
            val popupMenu = PopupMenu(this, it)
            popupMenu.setOnMenuItemClickListener { item ->
                when (item.itemId){
                    R.id.menu_settings -> {
                        startSettings()
                        true
                    }

                    R.id.menu_load -> {
                        clickSelectFile()
                        true
                    }

                    R.id.menu_add -> {

                        true
                    }

                    else -> false
                }
            }

            popupMenu.inflate(R.menu.menu_main)

            try {
                val fieldMPopup = PopupMenu::class.java.getDeclaredField("mPopup")
                fieldMPopup.isAccessible = true
                val mPopup = fieldMPopup.get(popupMenu)
                mPopup.javaClass
                    .getDeclaredMethod("setForceShowIcon",Boolean::class.java)
                    .invoke(mPopup, true)
            } catch (e: Exception) {
                Log.e("Main", "Error showing menu icons.", e)
            } finally {
                popupMenu.show()
            }
        }

        //set text file
        if (textFileStringSaved != ""){
            //set file
            textFileString = textFileStringSaved?: " & &"

            //enable button
            chevron_right.isClickable = true
            chevron_left.isClickable = true

            //new flashcard
            justRecreated = true
            clickNewFlashcard(card_FRONT)
        }



    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        //word file found
        if (requestCode == wordsFileRequestCode && resultCode == RESULT_OK) {
            val fileSelectedPath = data?.data
            val pref = PreferenceManager.getDefaultSharedPreferences(this)
            val editor = pref.edit()
            editor.putString(savedFilePath,fileSelectedPath.toString())
            if (fileSelectedPath != null) {
                //locals
                val inputStream = contentResolver.openInputStream(fileSelectedPath)

                //set file
                textFileString = inputStream.bufferedReader().use { it.readText() }

                //save text file
                editor.putString(savedWordsFile,textFileString)
                editor.commit()

                //render the flashcards
                clickNewFlashcard(flashcardFrontText)
            } else {
                //output no file exists
                Toast.makeText(this,"No Data", Toast.LENGTH_LONG).show()

                editor.commit()
            }
        }
    }



    fun clickFlipFlashcard(@Suppress("UNUSED_PARAMETER")view: android.view.View){
        //check whether file has been selected
        if (flashcardFrontText.text == resources.getString(R.string.textViewOutput_text)) {
            //run new user
            clickSelectFile()
        } else {
            //file selected run as usual
            flipAnimation()
        }
    }

    fun clickNewFlashcard(view: android.view.View){
        //create local variables
        val pref = PreferenceManager.getDefaultSharedPreferences(this)
        val flashcardFlipper = pref.getBoolean(savedFlashcardFlipper, false)
        val flashcardNumber = pref.getInt(savedFlashcardNumber, -1)
        val editor = pref.edit()
        val flashcardOrder = pref.getInt(savedFlashcardOrder,0)

        //read file and put to array
        val wordsFileArray = readWordsFile()

        //select appropriate output
        when (flashcardOrder){
            //random
            0 ->{
                //randomly select number and set relevant variables
                if (flashcardNumber == -1 || !justRecreated) {
                    cardSelected = if (wordsFileArrayCounter > 0) 2 * randomNumberGenerator(0, (wordsFileArrayCounter - 1) / 2) else 0

                    //save flashcard number
                    editor.putInt(savedFlashcardNumber,cardSelected)
                } else {
                    cardSelected = flashcardNumber
                    justRecreated = false
                }
            }

            //file order
            1 ->{
                //randomly select number and set relevant variables
                if (!justRecreated) {
                    //choose card selected
                    cardSelected =
                            if (flashcardNumber != -1)
                                if (view == chevron_left)
                                    if (wordsFileArrayCounter > flashcardNumber - 2)
                                        flashcardNumber - 2
                                    else flashcardNumber
                                else if (wordsFileArrayCounter > flashcardNumber + 2)
                                    flashcardNumber + 2
                                else 0
                            else 0


                    //save flashcard number
                    editor.putInt(savedFlashcardNumber,cardSelected)
                } else {
                    cardSelected = flashcardNumber
                    justRecreated = false
                }
            }
        }



        //reset variables
        wordsNotDefinition = true

        //save the values
        flashcardFrontText.text = wordsFileArray[cardSelected]
        flashcardBackText.text = wordsFileArray[cardSelected+1]

        //enable buttons
        chevron_left.isClickable = true
        chevron_right.isClickable = true

        //flip flashcard on flashcardFlipper
        if (flashcardFlipper) {
            flipAnimation()
        }

        //save flashcard value
        editor.commit()
    }

    private fun startSettings() {
        val intent = Intent(this, Settings::class.java).apply { }
        startActivity(intent)
    }

    private fun clickSelectFile(){
        //create locals
        val intent = Intent().setType("*/*").setAction(Intent.ACTION_GET_CONTENT)

        //request file
        startActivityForResult(Intent.createChooser(intent, "Select a file"), wordsFileRequestCode)
    }

    private fun readWordsFile(): kotlin.Array<String>{
        //create local variables
        val stringSplit = '&'
        val wordsFileArray = Array(textFileString.length/2){""}
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

    private fun flipAnimation(){
        //create locals
        val distance = 8000
        val scale = resources.displayMetrics.density * distance
        val firstFlip = AnimatorInflater.loadAnimator(this, R.animator.flashcard_flip1)
        val secondFlip = AnimatorInflater.loadAnimator(this, R.animator.flashcard_flip2)

        card_FRONT.cameraDistance = scale
        card_BACK.cameraDistance = scale

        if (!backOfCardVisible){
            firstFlip.setTarget(card_FRONT)
            secondFlip.setTarget(card_BACK)
            firstFlip.start()
            secondFlip.start()
            backOfCardVisible = true
        } else {
            firstFlip.setTarget(card_BACK)
            secondFlip.setTarget(card_FRONT)
            firstFlip.start()
            secondFlip.start()
            backOfCardVisible = false
        }
    }

}


