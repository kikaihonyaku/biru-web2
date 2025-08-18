import React, { useEffect, useState } from 'react';

export default function MapTest() {
  const [status, setStatus] = useState('checking');
  const [details, setDetails] = useState({});

  useEffect(() => {
    const testGoogleMapsAPI = async () => {
      const apiKey = 'AIzaSyA3guDBBdBgTbMWY2fiz9qskChCV4ZyESY';
      
      try {
        // 1. APIキーの基本テスト
        const testUrl = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&libraries=places`;
        
        setDetails(prev => ({
          ...prev,
          apiKey: apiKey ? 'Present' : 'Missing',
          testUrl: testUrl
        }));

        // 2. スクリプトの動的ロード
        const script = document.createElement('script');
        script.src = testUrl;
        script.async = true;
        script.defer = true;
        
        script.onload = () => {
          setStatus('success');
          setDetails(prev => ({
            ...prev,
            scriptLoaded: true,
            googleAvailable: typeof window.google !== 'undefined',
            mapsAvailable: typeof window.google?.maps !== 'undefined'
          }));
        };
        
        script.onerror = (error) => {
          setStatus('error');
          setDetails(prev => ({
            ...prev,
            scriptLoaded: false,
            error: 'Failed to load Google Maps script'
          }));
        };
        
        document.head.appendChild(script);
        
      } catch (error) {
        setStatus('error');
        setDetails(prev => ({
          ...prev,
          error: error.message
        }));
      }
    };

    testGoogleMapsAPI();
  }, []);

  return (
    <div style={{ padding: '20px', fontFamily: 'monospace' }}>
      <h2>Google Maps API Test</h2>
      <div style={{ 
        padding: '10px', 
        margin: '10px 0', 
        backgroundColor: status === 'success' ? '#d4edda' : status === 'error' ? '#f8d7da' : '#fff3cd',
        border: '1px solid ' + (status === 'success' ? '#c3e6cb' : status === 'error' ? '#f5c6cb' : '#ffeaa7'),
        borderRadius: '4px'
      }}>
        <strong>Status: {status}</strong>
      </div>
      
      <h3>Details:</h3>
      <pre style={{ 
        backgroundColor: '#f8f9fa', 
        padding: '10px', 
        borderRadius: '4px',
        overflow: 'auto'
      }}>
        {JSON.stringify(details, null, 2)}
      </pre>
      
      <h3>Troubleshooting:</h3>
      <ul>
        <li>APIキーが正しく設定されているか確認</li>
        <li>Google Cloud ConsoleでMaps JavaScript APIが有効になっているか確認</li>
        <li>ブラウザの開発者コンソールでエラーメッセージを確認</li>
        <li>請求情報が設定されているか確認（Google Maps API使用のため）</li>
        <li>APIキーの使用制限（HTTP referrer、IP制限など）を確認</li>
      </ul>
      
      {status === 'success' && (
        <div style={{ marginTop: '20px' }}>
          <h3>Simple Map Test:</h3>
          <div id="test-map" style={{ height: '300px', width: '100%', border: '1px solid #ccc' }}>
            {/* テスト用の地図がここに表示されます */}
          </div>
        </div>
      )}
    </div>
  );
}