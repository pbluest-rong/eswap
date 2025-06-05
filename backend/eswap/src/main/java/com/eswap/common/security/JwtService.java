package com.eswap.common.security;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.exception.AccountLockedException;
import com.eswap.common.exception.InvalidTokenException;
import com.eswap.common.exception.OperationNotPermittedException;
import com.eswap.model.User;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import io.jsonwebtoken.Jwts;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Service
public class JwtService {
    @Value("${spring.application.security.jwt.secret-key}")
    private String secretKey = "";
    @Value("${spring.application.security.jwt.expiration}")
    private long jwtExpiration;
    @Value("${spring.application.security.jwt.refresh-token.expiration}")
    private long refreshExpiration;

    public String generateRefreshToken(UserDetails userDetails) {
        return buildToken(new HashMap<>(), userDetails, refreshExpiration);
    }

    public String generateToken(UserDetails userDetails) {
        return generateToken(new HashMap<>(), userDetails);
    }

    public String generateToken(Map<String, Object> claims, UserDetails userDetails) {
        return buildToken(claims, userDetails, jwtExpiration);
    }

    private String buildToken(Map<String, Object> extraClaims, UserDetails userDetails, long jwtExpiration) {
        var authorities = userDetails.getAuthorities()
                .stream()
                .map(GrantedAuthority::getAuthority)
                .toList();
        // Thêm user ID vào claims nếu UserDetails là instance của User
        if (userDetails instanceof User) {
            extraClaims.put("userId", ((User) userDetails).getId());
        }
        return Jwts.builder()
                .setClaims(extraClaims)
                .setSubject(userDetails.getUsername())
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + jwtExpiration))
                .claim("authorities", authorities)
                .signWith(getSignInKey())
                .compact();
    }

    //    public boolean isTokenValid(String token, UserDetails userDetails) {
//        final String username = extractUserName(token);
//        return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
//    }
    public boolean isTokenValid(String token, UserDetails userDetails) {
        try {
            final String username = extractUserName(token);
            if (!username.equals(userDetails.getUsername())) {
                return false;
            }
            if (isTokenExpired(token)) {
                return false;
            }
            if (!userDetails.isEnabled()) {
                throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
            }
            if (!userDetails.isAccountNonLocked()) {
                throw new AccountLockedException(AppErrorCode.USER_LOCKED);
            }
            return true;
        } catch (ExpiredJwtException ex) {
            throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
        }
    }

    private boolean isTokenExpired(String token) {
        return extracExpiration(token).before(new Date());
    }

    private Date extracExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public String extractUserName(String token) {
        try {
            return extractClaim(token, Claims::getSubject);
        } catch (ExpiredJwtException e) {
            throw new InvalidTokenException(AppErrorCode.AUTH_TOKEN_EXPRIED);
        }
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimResolver) {
        final Claims claims = extractAllClaims(token);
        return claimResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts
                .parserBuilder()
                .setSigningKey(getSignInKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private Key getSignInKey() {
        byte[] ketBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(ketBytes);
    }

    public String generateTemporaryToken(String emailOrUsernameOrPhoneNumber) {
        Map<String, Object> claims = new HashMap<>();
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(emailOrUsernameOrPhoneNumber)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + 10 * 60 * 1000))
                .signWith(getSignInKey())
                .compact();
    }

    public boolean isTemporaryTokenValid(String token) {
        return !isTokenExpired(token);
    }
}