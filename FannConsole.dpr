program FannConsole;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  fann,
  Unit1 in 'Unit1.pas';

var ann: PFann;
  inputs: array[0..1] of fann_type;
  calc_out: PFann_Type_array;
  i, n, epochs, ebr: integer;
  err: real;
  s: string;
  l: array[0..9] of integer;
  train_data, test_data: PFann_Train_Data;

label
  start, loadconfig, traindata, testdata, forecast;

begin

  start:
  ClearScreen;
  Writeln('-- FannConsole 1.0.1 --');
  Writeln('Interactive console program based on the Fast Artificial Neural Network (FANN)');
  Writeln('Copyright MMXXII, Shpati Koleka. Program licensed under MIT license terms.');
  Writeln;

  loadconfig:
  Write('Would you like to load an existing network configuration? [Default = no] : ');
  Readln(s);
  if s = '' then s := 'no';
  if AnsiLowerCase(s[1]) = 'y' then
  begin
    Write('Please enter the name of the network config file. [Default = netconfig.txt] : ');
    Readln(s);
    if s = '' then s := 'netconfig.txt';
    if FileExists(s) = false then
    begin
      Writeln('The file is not found. Please place it in the same folder as the program.');
      Writeln;
      goto loadconfig;
    end;
    Writeln('Loading network configutation from ', s);
    Writeln;
    ann := fann_create_from_file(PAnsiChar(s));
    goto traindata;
  end;
  Writeln;

  Write('Please enter the total number of Layers [Default = 3] : ');
  Readln(s);
  if s = '' then s := '3';
  n := TryStrToInt(s, 3);
  if n > 10 then
  begin
    Writeln('The maximum number of Layers is 10');
    n := 10;
  end;
  if n < 2 then
  begin
    Writeln('The minimum number of Layers is 2');
    n := 2;
  end;
  Writeln('Layers = ', n);
  Writeln;
  for i := 0 to n - 1 do
  begin
    Write('Please enter the number of nodes for Layer ', i + 1, '. [Default = 1] : ');
    Readln(s);
    if s = '' then s := '1';
    l[i] := TryStrToInt(s, 1);
    Writeln('Layer ', i + 1, ' number of nodes = ', l[i]);
    Writeln;
  end;
  case n of
    10: ann := fann_create_standard(10, l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8], l[9]);
    9: ann := fann_create_standard(9, l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8]);
    8: ann := fann_create_standard(8, l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7]);
    7: ann := fann_create_standard(7, l[0], l[1], l[2], l[3], l[4], l[5], l[6]);
    6: ann := fann_create_standard(6, l[0], l[1], l[2], l[3], l[4], l[5]);
    5: ann := fann_create_standard(5, l[0], l[1], l[2], l[3], l[4]);
    4: ann := fann_create_standard(4, l[0], l[1], l[2], l[3]);
    3: ann := fann_create_standard(3, l[0], l[1], l[2]);
    2: ann := fann_create_standard(2, l[0], l[1]);
  end;

  traindata:
  Write('Would you like to train the network? [Default = yes] : ');
  Readln(s);
  Writeln;
  if s = '' then s := 'yes';
  if AnsiLowerCase(s[1]) <> 'y' then goto testdata;

  Write('Please enter the name of the train data file. [Default = train.dat] : ');
  Readln(s);
  if s = '' then s := 'train.dat';
  if FileExists(s) = false then
  begin
    Writeln('The file is not found. Please place it in the same folder as the program.');
    Writeln;
    goto traindata;
  end;
  Writeln('The train data file is ', s);
  Writeln;
  
  train_data := fann_read_train_from_file(PAnsiChar(s));

  fann_set_activation_steepness_hidden(ann, 0.5);
  fann_set_activation_steepness_output(ann, 0.5);

  fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC);
  fann_set_activation_function_output(ann, FANN_SIGMOID_SYMMETRIC);

  fann_set_train_stop_function(ann, FANN_STOPFUNC_BIT);
  fann_set_bit_fail_limit(ann, 0.001);

  fann_init_weights(ann, train_data);
  Write('Please enter the maximum number of epochs [Default = 500000] : ');
  Readln(s);
  if s = '' then s := '500000';
  epochs := TryStrToInt(s, 500000);
  Writeln('The maximum number of epochs = ', epochs);
  Writeln;

  Write('Please enter the number of epochs between reports [Default = 1000] : ');
  Readln(s);
  if s = '' then s := '1000';
  ebr := TryStrToInt(s, 1000);
  Writeln('The number of epochs between reports = ', ebr);
  Writeln;

  Write('Please enter the desired error [Default = 0.001] : ');
  Readln(s);
  if s = '' then s := '0.001';
  err := TryStrToFloat(s, 0.001);
  Writeln('The error = ', FormatFloat('0.#####', err));
  Writeln;

  fann_train_on_data(ann, train_data, epochs, ebr, err);
  Writeln;

  testdata:
  Write('Would you like to test the trained network? [Default = no] : ');
  Readln(s);
  if s = '' then s := 'no';
  if AnsiLowerCase(s[1]) = 'y' then
  begin
    Write('Please enter the name of the test data file. [Default = test.dat] : ');
    Readln(s);
    if s = '' then s := 'test.dat';
    if FileExists(s) = false then
    begin
      Writeln('The file is not found. Please place it in the same folder as the program.');
      Writeln;
      goto testdata;
    end;
    Writeln('The test data file is ', s);
    Writeln;
    test_data := fann_read_train_from_file(PAnsiChar(s));
    Writeln('The MSE is ', FormatFloat('0.#####', fann_test_data(ann, test_data)));
  end;
  Writeln;

  forecast:
  Write('Would you like to forecast? [Default = no] : ');
  Readln(s);
  if s = '' then s := 'no';
  if AnsiLowerCase(s[1]) = 'y' then
  begin
    for i := 0 to fann_get_num_input(ann) - 1 do
    begin
      Write('Enter value of node ', i + 1, ' from the Input Layer : ');
      Readln(s);
      inputs[i] := TryStrToFloat(s, 0);
    end;

    calc_out := fann_run(ann, @inputs[0]);
    write('Output = ');
      for i := 0 to fann_get_num_output(ann) - 2 do
        Write(FormatFloat('0.#####', Calc_Out[i]), ', ');
    Writeln(FormatFloat('0.#####', Calc_Out[fann_get_num_output(ann) - 1]));
    Writeln;
    goto forecast;
  end;
  Writeln;

  Write('Would you like to save the network config to a file? [Default = no] : ');
  Readln(s);
  if s = '' then s := 'no';
  if AnsiLowerCase(s[1]) = 'y' then
  begin
    Write('Please enter the file name [Default = netconfig.txt] : ');
    Readln(s);
    if s = '' then s := 'netconfig.txt';
    try
    fann_save(ann, PAnsiChar(s));
    except
    Writeln;
    end;
  end;
  Writeln;

  Write('Would you like to restart the program? [Default = yes] : ');
  Readln(s);
  Writeln;
  if s = '' then s := 'yes';
  if AnsiLowerCase(s[1]) = 'y' then goto start;
  fann_destroy(ann);

end.

