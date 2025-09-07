import React, { useState } from 'react';
import {
  Box,
  TextField,
  Button,
  Typography,
  Alert,
  Paper,
  Divider,
  CircularProgress,
} from '@mui/material';
import { useAuth } from '../../contexts/AuthContext';

const LoginForm = () => {
  const [formData, setFormData] = useState({
    code: '',
    password: '',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  
  const { login, loginWithGoogle } = useAuth();

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
    // エラーをクリア
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    if (!formData.code || !formData.password) {
      setError('社員番号とパスワードを入力してください');
      setLoading(false);
      return;
    }

    try {
      const result = await login(formData.code, formData.password);
      
      if (!result.success) {
        setError(result.error || 'ログインに失敗しました');
      }
      // 成功の場合、AuthContextがユーザー状態を更新し、
      // アプリケーションが自動的にリダイレクトします
      
    } catch (err) {
      setError('予期しないエラーが発生しました');
      console.error('Login error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignIn = () => {
    loginWithGoogle();
  };

  return (
    <Box
      sx={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '100vh',
        backgroundColor: '#f5f5f5',
        padding: 2,
      }}
    >
      <Paper
        elevation={3}
        sx={{
          padding: 4,
          maxWidth: 400,
          width: '100%',
        }}
      >
        <Typography
          variant="h4"
          component="h1"
          gutterBottom
          align="center"
          color="primary"
        >
          Biru Web
        </Typography>
        
        <Typography
          variant="h6"
          component="h2"
          gutterBottom
          align="center"
          color="textSecondary"
          sx={{ mb: 3 }}
        >
          ログイン
        </Typography>

        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        <Box component="form" onSubmit={handleSubmit} sx={{ mb: 3 }}>
          <TextField
            fullWidth
            label="社員番号"
            name="code"
            value={formData.code}
            onChange={handleChange}
            margin="normal"
            required
            autoFocus
            disabled={loading}
          />
          
          <TextField
            fullWidth
            label="パスワード"
            name="password"
            type="password"
            value={formData.password}
            onChange={handleChange}
            margin="normal"
            required
            disabled={loading}
          />
          
          <Button
            type="submit"
            fullWidth
            variant="contained"
            sx={{ mt: 3, mb: 2, py: 1.5 }}
            disabled={loading}
          >
            {loading ? (
              <CircularProgress size={24} color="inherit" />
            ) : (
              'ログイン'
            )}
          </Button>
        </Box>

        <Divider sx={{ my: 2 }}>
          <Typography variant="body2" color="textSecondary">
            または
          </Typography>
        </Divider>

        <Button
          fullWidth
          variant="outlined"
          onClick={handleGoogleSignIn}
          sx={{
            py: 1.5,
            borderColor: '#4285f4',
            color: '#4285f4',
            '&:hover': {
              backgroundColor: '#f8f9ff',
              borderColor: '#4285f4',
            },
          }}
          disabled={loading}
        >
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <img
              src="https://developers.google.com/identity/images/g-logo.png"
              alt="Google"
              style={{ width: 18, height: 18 }}
            />
            Googleでログイン
          </Box>
        </Button>
      </Paper>
    </Box>
  );
};

export default LoginForm;