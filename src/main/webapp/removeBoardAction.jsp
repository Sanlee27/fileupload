<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>    
<%@ page import = "java.io.*" %>
<%@ page import = "java.sql.*"%>
<%@ page import = "vo.*" %>
<%
	String dir = request.getServletContext().getRealPath("/upload");
	
	System.out.println(dir);
	
	int max = 10 * 1024 * 1024;
	
	// request 객체를 MultipartRequest의 API를 사용할 수 있도록 랩핑 request >> mreq(멀티파트~)
	MultipartRequest mreq = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());

	int boardNo = Integer.parseInt(mreq.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mreq.getParameter("boardFileNo"));
	String saveFilename = mRequest.getParameter("saveFilename");
	
	System.out.println(boardNo + " : removeBoardAction boardNo");
	System.out.println(boardFileNo + " : removeBoardAction boardFileNo");
	System.out.println(saveFilename + " : removeBoardAction saveFilename");
	
	//DB
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/fileupload";
	String dbuser = "root";
	String dbpw = "java1234";
	
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	File f = new File(dir+"/"+saveFilename);
	if(f.exists()){
		f.delete();
	
	String delSql = "DELETE FROM board WHERE board_no = ?";
	PreparedStatement delStmt =conn.prepareStatement(delSql);
	
	System.out.println(delStmt + " : removeBoardAction delStmt");
	
	delStmt.setInt(1, boardNo);
	
	int delRow = delStmt.executeUpdate();
	
	if(delRow == 1){
		System.out.println("삭제성공");
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	} else {
		System.out.println("삭제실패");
		response.sendRedirect(request.getContextPath()+"/removeBoard.jsp?boardNo="+boardNo+"&boardFileNo="+boardFileNo);
	}
%>
