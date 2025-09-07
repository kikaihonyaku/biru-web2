import React from 'react';
import { Box, CircularProgress, Typography } from '@mui/material';
import { useAuth } from '../../contexts/AuthContext';
import LoginForm from './LoginForm';

const PrivateRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();

  // 認証状態確認中はローディング表示
  if (loading) {
    return (
      <Box
        sx={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          height: '100vh',
          backgroundColor: '#f5f5f5',
        }}
      >
        <CircularProgress size={60} sx={{ mb: 2 }} />
        <Typography variant="h6" color="textSecondary">
          認証状態を確認中...
        </Typography>
      </Box>
    );
  }

  // 認証されていない場合はログインフォームを表示
  if (!isAuthenticated) {
    return <LoginForm />;
  }

  // 認証されている場合は保護されたコンテンツを表示
  return children;
};

export default PrivateRoute;