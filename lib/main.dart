import 'package:flutter/material.dart';
import 'music7.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayer2/audioplayer2.dart';
import 'package:volume/volume.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLAY XASSAIDE',
      theme: ThemeData(

      ),
      home: MyHomePage(title: 'PLAY XASSAIDE'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;

  /*List<Music> playlist=[
    new Music('Grave', 'Eddy de Pretto', 'assets/eddy.jpg', 'https://www.matieuio.fr/tutoriels/musiques/grave.mp3'),
    new Music('Nuvole Bianche', 'Ludovico Elnaudi',  'assets/le.jpg', 'https://www.matieuio.fr/tutoriels/musiques/nuvole_bianche.mp3'),
    new Music('These Day', 'Rudimenal',  'assets/thesed.jpg', 'https://www.matieuio.fr/tutoriels/musiques/these_days.mp3'),
  ];*/
   List<Music> playlist=[
    new Music('Maxtar Diene', 'Mawahibou', 'assets/maxtar.jpg', 'assets/Mawahibou.mp3'),
    new Music('Kurel HT', 'Juzbu',  'assets/ju.PNG', ''),
    new Music('Kurel HTDk', 'Mouxadimat',  'assets/mu.PNG', 'assets/Mouhadimat.mp3'),
  ];
  AudioPlayer audioPlayer;
  Music actualMusic ;
  int index =0;
  StreamSubscription positionSubscription;
  StreamSubscription stateSubscription;
  Duration  position = new Duration(seconds: 0);
  Duration duree= new Duration(seconds: 30);
  PlayerState statut = PlayerState.STOPED;
  bool mute = false;
  int maxVol= 0 , currentVol=0;

  void initState(){
    super.initState();
    actualMusic=playlist[index];
    configAudioPlayer();
    initPlatformState();
    updateVolume();

  }


  @override
  Widget build(BuildContext context) {
    double largeur = MediaQuery.of(context).size.width;
    int newVol= getVolumePourcent().toInt();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 50,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              width: 200,
              color: Colors.red,
              margin: EdgeInsets.only(top :20.0),
              child: new Image.asset(actualMusic.imagePath),
            ),
            new Container(
              margin: EdgeInsets.only(top:20.0),
              child: new Text(
                  actualMusic.titre,
                textScaleFactor: 1.5,
              ),
            ),
            new Container(
              margin: EdgeInsets.only(top:5.0),
              child: new Text(
                actualMusic.auteur,
              ),
            ),
            new Container(
              height: largeur / 5,
              margin: EdgeInsets.only(left : 10.0 , right: 10.0),
              child: new Row (
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:<Widget> [
                  new IconButton(
                      icon: new Icon(Icons.fast_rewind),
                      onPressed: rewind
                  ),
                  new IconButton(
                      icon: (statut != PlayerState.PLAYING) ? new Icon(Icons.play_arrow) :new Icon(Icons.pause),
                      onPressed: (statut != PlayerState.PLAYING) ? play : pause ,
                    iconSize: 50,
                  ),
                  new IconButton(
                      icon: (mute) ? new Icon(Icons.headset_off):new Icon(Icons.headset),
                      onPressed: muted
                  ),
                  new IconButton(
                      icon: new Icon(Icons.fast_forward),
                      onPressed: forward
                  )
                ],

              )
            ),
            new Container(
              margin: EdgeInsets.only(left: 10.0 , right: 10.0),
              child : new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  textWithStyle(fromDuration(position), 0.8),
                  textWithStyle(fromDuration(duree), 0.8)
                ],
              )
            ),
            new Container(
              margin: EdgeInsets.only(left: 10.0 , right: 10.0),
              child: new Slider(
                  value: position.inSeconds.toDouble(),
                  min:0.0,
                  max:duree.inSeconds.toDouble(),
                  inactiveColor: Colors.grey[500],
                  activeColor: Colors.deepPurple,
                  onChanged: (double d){
                    setState(() {
                      audioPlayer.seek(d);
                    });
                  }
              ),
            ),
            new Container(
              height: largeur / 5,
              margin: EdgeInsets.only(left: 5.0 ,right: 5.0 ,top: 0.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:<Widget> [
                  new IconButton(
                      icon: new Icon(
                        Icons.remove
                      ),
                      iconSize: 18,
                      onPressed: (){
                        if(!mute){
                          //Volume.volDown();
                          updateVolume();
                        }
                      }
                  ),
                  new Slider(
                      value:(mute) ? 0.0 : currentVol.toDouble(),
                      min:0.0,
                      max:maxVol.toDouble(),
                      inactiveColor: (mute) ? Colors.red : Colors.grey[500],
                      activeColor: (mute) ? Colors.red : Colors.blue,
                      onChanged: (double d){
                        setState(() {
                          if(!mute){
                            Volume.setVol(d.toInt());
                            updateVolume();
                          }
                        });
                      }
                  ),

                  new Text((mute)  ? 'Mute' : '$newVol'),
                  new IconButton(
                    icon: new Icon(
                        Icons.add
                      ),
                    iconSize: 18,
                    onPressed: (){
                      if(!mute){
                        //Volume.volUp();
                        updateVolume();
                      }
                    }
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );


  }
  double getVolumePourcent(){
    return (currentVol / maxVol) *100;
  }
  Future<void> initPlatformState() async {
    await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  }
  updateVolume() async {
    maxVol = await Volume.getMaxVol;
    currentVol = await Volume.getVol;
    setState(() {

    });
  }
  setVol(int i) async {
    await Volume.setVol(i);
  }
  Text textWithStyle(String data , double scale){
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign:TextAlign.center,
      style : new TextStyle(
        color: Colors.black,
        fontSize: 15.0,
      )
    );
  }
  IconButton bouton(IconData icone, double taille , ActionMusic action){
    return new IconButton(
        icon: new Icon(icone),
        onPressed: (){
          switch(action){
            case ActionMusic.PLAY:
              play();
              break;
            case ActionMusic.PAUSE:
              pause();
              break;
            case ActionMusic.REWIND:
              rewind();
              break;
            case ActionMusic.FORWARD:
              forward();
              break;
            default:
              break;
          }
        },
        iconSize: taille,
        color: Colors.white,
    );
  }
  void configAudioPlayer(){
    audioPlayer = new AudioPlayer();
    positionSubscription = audioPlayer.onAudioPositionChanged.listen((pos) {
      setState(() {
        position = pos;
      });
      if(position >= duree){
        position = new Duration(seconds: 0);
        //Passer a la Musique Suivant (forward);
      }
    });
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if(state == AudioPlayerState.PLAYING){
        setState(() {
          duree = audioPlayer.duration;
        });
      }
      else if (state == AudioPlayerState.STOPPED){
        setState(() {
          statut = PlayerState.STOPED;
        });
      }
    },onError: (message){
      print(message);
      setState(() {
        statut= PlayerState.STOPED;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    }
    );
  }
  Future play() async {
    await audioPlayer.play(actualMusic.musicURL);
    setState(() {
      statut = PlayerState.PLAYING;
    });
  }
  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.PAUSED;
    });
  }
  Future muted() async {
    await audioPlayer.mute(!mute);
    setState(() {
      mute = !mute;
    });
  }
  void forward(){
    if (index == playlist.length -1){
      index =0;
    }
    else{
      index ++;
    }
    actualMusic = playlist[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
  }
  void rewind(){
    if (position > Duration(seconds: 3)){
      audioPlayer.seek(0.0);
    }
    else{
      if(index == 0){
        index = playlist.length -1;
      } else {
        index --;
      }
    }
    actualMusic = playlist[index];
    audioPlayer.stop();
    configAudioPlayer();
    play();
  }
  String fromDuration(Duration duree){
    return duree.toString().split('.').first;
  }
}

enum ActionMusic{
  PLAY,
  PAUSE,
  REWIND,
  FORWARD

}
enum PlayerState{
  PLAYING,
  PAUSED,
  STOPED,
}