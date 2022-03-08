program qywxmessage;

uses
  sysutils,
  classes,
  fphttpclient,
  openssl,
  opensslsockets,
  fpjson,
  jsonparser;

const
  wx_ID = 'wwcxxxxxxxxxxxxxx';
  wx_SECRET = 'Xxl-xxxxxxxxxxxxxxxxxxxxxxxxxxxx';
  wx_AGENTID = '1000001';

var
  Client: TFPHttpClient;
  PClient: TFPHttpClient;
  S: String;
  jData : TJSONData;
  jObject : TJSONObject;
  wx_access_token : String;
  post_content : String;
  output_str : String;
  json_str: String;
  Response : TStringStream;

begin

  { SSL initialization has to be done by hand here }
  InitSSLInterface;

  Client := TFPHttpClient.Create(nil);
  try
    try
      { Allow redirections }
      Client.AllowRedirect := true;
      S := Client.Get('https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid='+wx_ID+'&corpsecret='+wx_SECRET);
    except
      on E: EHttpClient do
        writeln(E.Message)
      else
        raise;
    end;
  finally
    Client.Free;
  end;

  jData := GetJSON(S);
  jObject := jData as TJSONObject;
  wx_access_token := jObject.Get('access_token');
  jData.Free;
  writeln(wx_access_token);
  post_content := '''Message send to QYWX''';
  json_str := '{"touser": "@all","msgtype": "text","agentid":' + wx_AGENTID + ',"text": {"content": ' + post_content + '},"safe": 0,"debug": 1}';
  jData := GetJSON(json_str);
  output_str := jData.AsJSON;

  PClient := TFPHttpClient.Create(nil);
  PClient.AddHeader('User-Agent','Mozilla/5.0 (compatible; fpweb)');
  PClient.AddHeader('Content-Type','application/json; charset=UTF-8');
  PClient.AddHeader('Accept', 'application/json');
  PClient.AllowRedirect := true;
  PClient.RequestBody := TRawByteStringStream.Create(output_str);
  Response := TStringStream.Create('');
  try
        try
            PClient.Post('https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token='+wx_access_token, Response);
            writeln(Response.DataString);
            writeln('Response Code is ' + inttostr(Client.ResponseStatusCode));   // better be 200
        except on E:Exception do
                writeln('Something bad happened : ' + E.Message);
        end;
    finally
        PClient.RequestBody.Free;
        PClient.Free;
        Response.Free;
    end;

end.
