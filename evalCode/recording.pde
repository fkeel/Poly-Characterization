
class RecordManager {
  
  ArrayList<int[]> chipValues = new ArrayList<int[]>();
  ArrayList<Float> nmValues = new ArrayList<Float>(); // Newtonmeter values
  boolean recordN; // tells whether newtonmeter data are recorded
  
  void clearValues() {
    chipValues.clear();
    nmValues.clear();
  }
   
  void addValues(int[] values) { chipValues.add(values); }
  
  void addNMValue(float value) { nmValues.add(value); }
  
  void recordNM(boolean r) { recordN = r; }
  
  boolean recordingNM() { return recordN; }
  
  void record(int textID, String taskname, int weight) {
    for(int vi=0; vi<chipValues.size(); vi++) {
      String line = String.format("%d,%d,%s,", textID, millis(), taskname);
      for(int v: chipValues.get(vi)) {
        line += v+",";
      }
      if(recordN) { line += nmValues.get(vi)+","; }
      line += weight+",";
      appendTextToFile(filename, line.substring(0, line.length()-1)+"\n");
    }
  }
};
