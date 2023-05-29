<%@page import="java.lang.reflect.Member"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "java.net.*"%>
<%@ page import = "vo.*" %>    
<%    
	// 세션 유효성 검사
	if(session.getAttribute("loginMemberId") != null){
		response.sendRedirect(request.getContextPath()+"/home.jsp");
		return;
	}

	// 요청 유효성 검사
	String memberId = request.getParameter("memberId");
	String memberPw = request.getParameter("memberPw");
	
	System.out.println("loginAction memberId : " + memberId);
	System.out.println("loginAction memberPw : " + memberPw);
	
	// DB
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// 쿼리
	String sql = "SELECT member_id memberId FROM member WHERE member_id = ? AND member_pw = PASSWORD(?)";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setString(1, memberId);
	stmt.setString(2, memberPw);
	
	ResultSet rs = stmt.executeQuery();
	
	// 로그인 성공 유무
	if(rs.next()){
		//성공시 세션 저장
		session.setAttribute("loginMemberId", rs.getString("memberId"));
		System.out.println("로그인 정보 : " + session.getAttribute("loginMemberId"));
	} else {
		System.out.println("로그인 실패");
	}
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
 %>